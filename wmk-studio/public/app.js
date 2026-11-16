const $=id=>document.getElementById(id),storage={docs:[],current:null,editor:null};
const templates=[
{name:'JS Godot — Personagem 2D',area:'2D',language:'javascript',code:`"use strict";
const {CharacterBody2D,Input,Vector2}=require("godot");
exports.default=class Jogador extends CharacterBody2D {
  velocidade=220;
  _physics_process(delta) {
    const d=Input.get_vector("ui_left","ui_right","ui_up","ui_down");
    this.velocity=new Vector2(d.x*this.velocidade,d.y*this.velocidade);
    this.move_and_slide();
  }
};`},
{name:'GDScript — Personagem 2D',area:'2D',language:'gdscript',code:`extends CharacterBody2D
@export var velocidade := 220.0
func _physics_process(_delta):
    velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * velocidade
    move_and_slide()`},
{name:'JS Godot — Personagem 3D',area:'3D',language:'javascript',code:`"use strict";
const {CharacterBody3D,Input,Vector3}=require("godot");
exports.default=class Jogador3D extends CharacterBody3D {
  velocidade=5;
  _physics_process(delta) {
    const d=Input.get_vector("ui_left","ui_right","ui_up","ui_down");
    const v=this.velocity;
    this.velocity=new Vector3(d.x*this.velocidade,this.is_on_floor()?0:v.y-9.8*delta,d.y*this.velocidade);
    this.move_and_slide();
  }
};`},
{name:'GDScript — Personagem 3D',area:'3D',language:'gdscript',code:`extends CharacterBody3D
@export var velocidade := 5.0
func _physics_process(delta):
    var d := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    velocity.x = d.x * velocidade
    velocity.z = d.y * velocidade
    if not is_on_floor(): velocity.y -= 9.8 * delta
    else: velocity.y = 0
    move_and_slide()`},
{name:'HTML — Página básica',area:'Geral',language:'html',code:'<!doctype html>\n<html lang="pt-BR"><head><meta charset="utf-8"></head><body><h1>WMK</h1></body></html>'},
{name:'Python — Classe básica',area:'Geral',language:'python',code:'class Jogador:\n    def __init__(self, nome):\n        self.nome = nome\n\nprint(Jogador("WMK").nome)'}
];
const ext={javascript:'js',typescript:'ts',gdscript:'gd',python:'py',csharp:'cs',lua:'lua',cpp:'cpp',rust:'rs',html:'html',css:'css',php:'php',json:'json'};
const lang=()=>({gdscript:'python',csharp:'csharp',cpp:'cpp'}[$('language').value]||$('language').value);
function code(){return storage.editor?storage.editor.getValue():$('fallback').value}
function setCode(v){if(storage.editor)storage.editor.setValue(v);$('fallback').value=v}
async function api(url,method='GET',data){const res=await fetch(url,{method,headers:{'Content-Type':'application/json'},body:data===undefined?undefined:JSON.stringify(data)});const x=await res.json();if(!res.ok)throw Error(x.error||'Erro');return x}
const alertError=e=>alert(e.message||String(e));
function edit(x){storage.current=x?.id||null;$('title').value=x?.title||'';$('area').value=x?.area||'2D';$('language').value=x?.language||'javascript';$('tags').value=x?.tags||'';setCode(x?.code||'');storage.editor?.getModel()?.setLanguage?.(lang());if(storage.editor&&window.monaco)window.monaco.editor.setModelLanguage(storage.editor.getModel(),lang())}
function render(){const q=$('search').value.toLowerCase(),area=$('area').value;$('items').replaceChildren();for(const x of storage.docs.filter(v=>(area==='Geral'||v.area===area||v.area==='Geral')&&[v.title,v.tags,v.language].join(' ').toLowerCase().includes(q))){const b=document.createElement('button');b.className='item';b.textContent=x.title;const sm=document.createElement('small');sm.textContent=x.area+' · '+x.language;b.append(sm);b.onclick=()=>edit(x);$('items').append(b)}}
async function reload(){storage.docs=await api('/api/docs');render()}
function download(name,content,mime='text/plain'){const a=document.createElement('a'),u=URL.createObjectURL(new Blob([content],{type:mime}));a.href=u;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(u),1000)}
$('new').onclick=()=>edit(null);
$('save').onclick=async()=>{try{const x=await api('/api/docs','POST',{id:storage.current,title:$('title').value,area:$('area').value,language:$('language').value,tags:$('tags').value,code:code()});storage.current=x.id;await reload();$('status').textContent='✓ Código salvo'}catch(e){alertError(e)}};
$('delete').onclick=async()=>{if(!storage.current||!confirm('Excluir este código?'))return;try{await api('/api/docs/'+encodeURIComponent(storage.current),'DELETE');edit(null);await reload()}catch(e){alertError(e)}};
$('search').oninput=render;$('area').onchange=render;$('language').onchange=()=>{if(storage.editor&&window.monaco)monaco.editor.setModelLanguage(storage.editor.getModel(),lang())};
$('copy').onclick=()=>navigator.clipboard.writeText(code()).catch(alertError);
$('download').onclick=()=>download(($('title').value||'codigo').replace(/[^a-z0-9_-]/gi,'_')+'.'+(ext[$('language').value]||'txt'),code());
$('export').onclick=()=>download('wmk-biblioteca.json',JSON.stringify(storage.docs,null,2),'application/json');
$('import').onclick=()=>$('jsonfile').click();
$('jsonfile').onchange=async()=>{try{const list=JSON.parse(await $('jsonfile').files[0].text());if(!Array.isArray(list))throw Error('Formato esperado: lista JSON');if(!confirm('Substituir biblioteca atual?'))return;await api('/api/import','POST',{docs:list});edit(null);await reload()}catch(e){alertError(e)}};
for(const [i,t] of templates.entries()){const o=document.createElement('option');o.value=i;o.textContent=t.name;$('template').append(o)}
$('apply').onclick=()=>{const t=templates[Number($('template').value)];if(!t)return;if(code().trim()&&!confirm('Substituir código atual pelo template?'))return;edit({...t,id:null,tags:'template'})};
$('copyanswer').onclick=()=>navigator.clipboard.writeText($('answer').textContent).catch(alertError);
async function providers(){const all=await api('/api/providers');const current=all.find(x=>x.id===$('provider').value);$('configured').textContent=current?(current.configured?'✓ Configurado':'⚠ Sem chave no .env')+' · '+current.model:''}
$('provider').onchange=()=>providers().catch(alertError);
$('ask').onclick=async()=>{const btn=$('ask');btn.disabled=true;$('answer').textContent='Consultando provedor...';try{const prompt=$('task').value+'\n'+$('question').value+'\n\nCódigo:\n'+code();const r=await api('/api/ai','POST',{provider:$('provider').value,prompt,area:$('area').value,language:$('language').value});$('answer').textContent=r.reply}catch(e){$('answer').textContent='Erro: '+e.message}finally{btn.disabled=false}};
reload().catch(alertError);providers().catch(alertError);
if(window.require){try{window.require.config({paths:{vs:'https://cdn.jsdelivr.net/npm/monaco-editor@0.52.2/min/vs'}});window.require(['vs/editor/editor.main'],()=>{storage.editor=monaco.editor.create($('editor'),{value:$('fallback').value,language:lang(),theme:'vs-dark',automaticLayout:true,minimap:{enabled:false},fontSize:14,wordWrap:'on'});$('fallback').style.display='none';$('editor').style.display='block'},()=>{$('editor').style.display='none';$('fallback').style.display='block'})}catch{$('editor').style.display='none';$('fallback').style.display='block'}}else{$('editor').style.display='none';$('fallback').style.display='block'}
