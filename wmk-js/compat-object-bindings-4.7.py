#!/usr/bin/env python3
"""Port GodotJS bridge object binding and animation editor helper to Godot 4.7.

WMK CodeVerse - Walney Moreira Klein - walneyk@hotmail.com
"""
import argparse
from pathlib import Path

def once(src, old, new, label):
    count = src.count(old)
    if count != 1:
        raise ValueError(f"{label}: expected one occurrence, found {count}")
    return src.replace(old, new, 1)

def apply(root: Path):
    module = root / "modules/GodotJS"
    object_file = module / "bridge/jsb_object_bindings.cpp"
    environment_file = module / "bridge/jsb_environment.cpp"
    helper_file = module / "weaver-editor/jsb_editor_helper.cpp"

    class_helper = """
    // In Godot 4.7 ClassDB::ClassInfo no longer stores its class name.
    // Resolve via the owning ClassDB map, without altering upstream engine structs.
    static StringName wmk_class_name(const ClassDB::ClassInfo *info) {
        if (info == nullptr) {
            return StringName();
        }
        for (const KeyValue<StringName, ClassDB::ClassInfo> &item : ClassDB::classes) {
            if (&item.value == info) {
                return item.key;
            }
        }
        return StringName();
    }

"""

    obj = object_file.read_text(encoding="utf-8-sig")
    obj = once(obj, "namespace jsb\n{\n    static Variant::Type", "namespace jsb\n{\n"+class_helper+"    static Variant::Type", "object helper")
    if obj.count("p_class_info->name") < 4:
        raise ValueError("Expected multiple obsolete class names in object bindings")
    obj = obj.replace("p_class_info->name", "wmk_class_name(p_class_info)")
    obj = obj.replace("p_class_info->inherits_ptr->name", "wmk_class_name(p_class_info->inherits_ptr)")
    start = "             // class: signals\n"
    end = "            // set `class_id` on the exposed godot native class"
    if obj.count(start) != 1 or obj.count(end) != 1:
        raise ValueError("Object binding reflection markers changed")
    prefix, tail = obj.split(start, 1)
    previous, suffix = tail.split(end, 1)
    new = """             // class: signals
             List<MethodInfo> signals;
             ClassDB::get_signal_list(wmk_class_name(p_class_info), &signals, true);
             for (const MethodInfo &signal : signals)
             {
                 v8::HandleScope scope(isolate);
                 const StringName signal_key = signal.name;
                 String signal_name = internal::NamingUtil::get_member_name(signal_key);
                 const v8::Local<v8::String> signal_js = p_env->get_string_name_cache().get_string_value(isolate, signal_key);
                 class_builder.Instance().Property(signal_name, _godot_object_signal_get, signal_js.As<v8::Value>());
             }

             HashSet<StringName> enum_consts;
             List<StringName> enums;
             ClassDB::get_enum_list(wmk_class_name(p_class_info), &enums, true);
             for (const StringName &enum_name : enums)
             {
                 v8::HandleScope scope(isolate);
                 auto enumeration = static_builder.Enum(internal::NamingUtil::get_enum_name(enum_name));
                 List<StringName> values;
                 ClassDB::get_enum_constants(wmk_class_name(p_class_info), enum_name, &values, true);
                 for (const StringName &constant : values)
                 {
                     const String js_name = internal::NamingUtil::get_enum_value_name(constant);
                     jsb_not_implemented(js_name.contains("."), "nested definition not supported");
                     enumeration.Value(js_name, ClassDB::get_integer_constant(wmk_class_name(p_class_info), constant));
                     enum_consts.insert(constant);
                 }
             }

             // class: constants not covered by enums
             List<String> constants;
             ClassDB::get_integer_constant_list(wmk_class_name(p_class_info), &constants, true);
             for (const String &constant : constants)
             {
                 const StringName name = StringName(constant);
                 if (enum_consts.has(name)) continue;
                 const String js_name = internal::NamingUtil::get_constant_name(name);
                 jsb_not_implemented(js_name.contains("."), "nested definition not supported");
                 static_builder.Value(name, ClassDB::get_integer_constant(wmk_class_name(p_class_info), name));
             }

"""
    obj = prefix + start + new.split(start, 1)[1] + end + suffix
    for old_field in ["->signal_map", "->enum_map", "->constant_map", "->name"]:
        if "p_class_info" + old_field in obj:
            raise ValueError(f"Unported object binding field: {old_field}")
    object_file.write_text(obj, encoding="utf-8")

    env = environment_file.read_text(encoding="utf-8-sig")
    env = once(env, "namespace jsb\n{", "namespace jsb\n{\n"+class_helper, "environment helper")
    env = once(env, "internal::NamingUtil::get_class_name(p_class_info->name)",
               "internal::NamingUtil::get_class_name(wmk_class_name(p_class_info))", "environment class lookup")
    environment_file.write_text(env, encoding="utf-8")

    helper = helper_file.read_text(encoding="utf-8-sig")
    if helper.count("List<StringName> library_names;") != 1 or helper.count("List<StringName> animation_names;") != 1:
        raise ValueError("Animation helper targets missing")
    helper = helper.replace("List<StringName> library_names;", "LocalVector<StringName> library_names;")
    helper = helper.replace("List<StringName> animation_names;", "LocalVector<StringName> animation_names;")
    helper_file.write_text(helper, encoding="utf-8")
    print("WMK: ClassDB 4.7 object bindings and animation editor helper migrated.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("engine", type=Path)
    apply(parser.parse_args().engine)
