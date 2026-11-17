#!/usr/bin/env python3
"""GodotJS 4.7 compatibility: migrate editor type reflection to public ClassDB APIs.

This deliberately fails when upstream source changes unexpectedly.
WMK CodeVerse — Walney Moreira Klein — walneyk@hotmail.com
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path


def replace_once(code: str, old: str, new: str, label: str) -> str:
    count = code.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected one occurrence, found {count}")
    return code.replace(old, new, 1)


def replace_region(code: str, start: str, end: str, new: str, label: str) -> str:
    if code.count(start) != 1:
        raise RuntimeError(f"{label}: start marker is ambiguous/missing")
    prefix, tail = code.split(start, 1)
    if end not in tail:
        raise RuntimeError(f"{label}: end marker not found")
    _, suffix = tail.split(end, 1)
    return prefix + start + new + end + suffix


def patch(code: str) -> str:
    code = replace_once(
        code,
        "namespace jsb\n{\n    namespace\n    {\n        template<int N>",
        """namespace jsb
{
    namespace
    {
        // Godot 4.7 removed ClassDB::ClassInfo::EnumInfo.
        // This structure holds only the metadata needed for GodotJS reflection.
        struct WMKEnumInfo {
            List<StringName> constants;
            bool is_bitfield = false;
        };

        template<int N>""",
        "WMKEnumInfo",
    )
    count = code.count("ClassDB::ClassInfo::EnumInfo")
    if count < 3:
        raise RuntimeError(f"ClassDB enum migration expected >= 3 occurrences, got {count}")
    code = code.replace("ClassDB::ClassInfo::EnumInfo", "WMKEnumInfo")
    code = replace_once(
        code,
        "internal::NamingUtil::get_class_name(class_info.inherits)",
        "internal::NamingUtil::get_class_name(ClassDB::get_parent_class(class_name))",
        "parent class",
    )

    code = replace_region(
        code,
        "            // class: enums\n",
        "            // class: constants (int only)",
        """            {
                JSB_HANDLE_SCOPE(isolate);
                List<StringName> enum_names;
                ClassDB::get_enum_list(class_name, &enum_names, true);
                v8::Local<v8::Array> enums_obj = v8::Array::New(isolate, (int) enum_names.size());
                set_field(isolate, context, class_info_obj, "enums", enums_obj);
                int index = 0;
                ConstantHashMap constant_values;
                List<String> all_constants;
                ClassDB::get_integer_constant_list(class_name, &all_constants, true);
                for (const String &name : all_constants) {
                    const StringName key = StringName(name);
                    constant_values.insert(key, ClassDB::get_integer_constant(class_name, key));
                }
                for (const StringName &enum_name : enum_names) {
                    JSB_HANDLE_SCOPE(isolate);
                    WMKEnumInfo enum_info;
                    ClassDB::get_enum_constants(class_name, enum_name, &enum_info.constants, true);
                    enum_info.is_bitfield = ClassDB::is_enum_bitfield(class_name, enum_name, true);
                    v8::Local<v8::Object> enum_info_obj = v8::Object::New(isolate);
                    set_field(isolate, context, enum_info_obj, "name", internal::NamingUtil::get_enum_name(enum_name));
                    build_enum_info(isolate, context, constant_values, enum_name, enum_info, enum_info_obj);
                    enums_obj->Set(context, index++, enum_info_obj).Check();
                }
            }

""",
        "enum list",
    )

    code = replace_region(
        code,
        "            // class: constants (int only)\n",
        "            // class: signals",
        """            {
                JSB_HANDLE_SCOPE(isolate);
                List<String> constant_names;
                ClassDB::get_integer_constant_list(class_name, &constant_names, true);
                v8::Local<v8::Array> constants_obj = v8::Array::New(isolate, (int) constant_names.size());
                set_field(isolate, context, class_info_obj, "constants", constants_obj);
                int index = 0;
                for (const String &constant_name : constant_names) {
                    JSB_HANDLE_SCOPE(isolate);
                    v8::Local<v8::Object> constant_info_obj = v8::Object::New(isolate);
                    const StringName key = StringName(constant_name);
                    set_field(isolate, context, constant_info_obj, "name", internal::NamingUtil::get_constant_name(key));
                    set_field(isolate, context, constant_info_obj, "value", ClassDB::get_integer_constant(class_name, key));
                    constants_obj->Set(context, index++, constant_info_obj).Check();
                }
            }

""",
        "constant list",
    )

    code = replace_region(
        code,
        "            // class: signals\n",
        "            return class_info_obj;",
        """            {
                JSB_HANDLE_SCOPE(isolate);
                List<MethodInfo> signals;
                ClassDB::get_signal_list(class_name, &signals, true);
                v8::Local<v8::Array> signals_obj = v8::Array::New(isolate, (int) signals.size());
                set_field(isolate, context, class_info_obj, "signals", signals_obj);
                int index = 0;
                for (const MethodInfo &signal : signals) {
                    JSB_HANDLE_SCOPE(isolate);
                    v8::Local<v8::Object> signal_info_obj = v8::Object::New(isolate);
                    set_field(isolate, context, signal_info_obj, "internal_name", signal.name);
                    set_field(isolate, context, signal_info_obj, "name", internal::NamingUtil::get_member_name(signal.name));
                    build_signal_info(isolate, context, signal, signal_info_obj);
                    signals_obj->Set(context, index++, signal_info_obj).Check();
                }
            }

""",
        "signal list",
    )
    if re.search(r"class_info\.(?:enum_map|constant_map|signal_map|inherits)\b", code):
        raise RuntimeError("obsolete ClassInfo member still used")
    return code


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("engine", type=Path)
    args = parser.parse_args()
    target = args.engine / "modules/GodotJS/bridge/jsb_editor_utility_funcs.cpp"
    before = target.read_text(encoding="utf-8-sig")
    after = patch(before)
    target.write_text(after, encoding="utf-8")
    print("WMK Godot 4.7: migrated JS reflection to public ClassDB API")


if __name__ == "__main__":
    main()
