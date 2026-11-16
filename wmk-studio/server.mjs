import http from 'node:http';
import fs from 'node:fs/promises';
import {readFileSync,existsSync} from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import crypto from 'node:crypto';
const root=path.dirname(fileURLToPath(import.meta.url)),pub=path.join(root,'public'),store=path.join(root,'data','biblioteca.json');
const env=path.join(root,'.env');
if(existsSync(env)) for(const line of readFileSync(env,'utf8').split(/\r?\n/)){const m=line.match(/^\s*([A-Z][A-Z0-9_]*)\s*=\s*(.*?)\s*$/);if(m&&!Object.hasOwn(process.env,m[1]))process.env[m[1]]=m[2].replace(/^["']|["']$/g,'')}
const port=Number(process.env.PORT||4178);
const models={groq:['GROQ_API_KEY','GROQ_MODEL','llama-3.3-70b-versatile'],openai:['OPENAI_API_KEY','OPENAI_MODEL','gpt-4.1-mini'],gemini:['GEMINI_API_KEY','GEMINI_MODEL','gemini-2.5-flash'],ollama:[null,'OLLAMA_MODEL','qwen2.5-coder:7b']};
const send=(res,status,data)=>{res.writeHead(status,{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'});res.end(JSON.stringify(data))};
const clip=(v,n)=>typeof v==='string'?v.slice(0,n):'';
async function readDocs(){try{const a=JSON.parse(await fs.readFile(store,'utf8'));return Array.isArray(a)?a:[]}catch(e){if(e.code==='ENOENT')return [];throw e}}
async function saveDocs(a){await fs.mkdir(path.dirname(store),{recursive:true});const tmp=store+'.'+crypto.randomUUID()+'.tmp';await fs.writeFile(tmp,JSON.stringify(a,null,2));await fs.rename(tmp,store)}
async function readBody(req){let buf='';for await(const chunk of req){buf+=chunk;if(buf.length>300000)throw Error('Entrada excede o limite')}return JSON.parse(buf||'{}')}
const sys='Você é o WMK CodeBot, agente de programação para jogos 2D e 3D, GDScript, JavaScript, TypeScript, C#, Lua, C++, Rust, Python e linguagens web. Responda em português brasileiro; explique arquitetura, bugs, segurança e boas práticas. Não afirme que testou código sem realmente executá-lo.';
async function ask(x){
 const p=models[x.provider];if(!p)throw Error('Provedor inválido');
 const model=process.env[p[1]]||p[2],key=p[0]&&process.env[p[0]];
 if(x.provider!=='ollama'&&!key)throw Error('Configure '+p[0]+' em .env');
 const content='Ambiente: '+clip(x.area,20)+'; linguagem: '+clip(x.language,30)+'\n\n'+clip(x.prompt,24000);
 let url,headers={'Content-Type':'application/json'},payload;
 if(x.provider==='gemini'){
   url='https://generativelanguage.googleapis.com/v1beta/models/'+encodeURIComponent(model)+':generateContent';
   headers['x-goog-api-key']=key;
   payload={systemInstruction:{parts:[{text:sys}]},contents:[{role:'user',parts:[{text:content}]}]};
 }else if(x.provider==='ollama'){
   const base=new URL(process.env.OLLAMA_URL||'http://127.0.0.1:11434');
   if(!['127.0.0.1','localhost','::1'].includes(base.hostname))throw Error('Ollama deve estar em localhost');
   url=new URL('/api/chat',base).toString();
   payload={model,stream:false,messages:[{role:'system',content:sys},{role:'user',content}]};
 }else{
   url=x.provider==='groq'?'https://api.groq.com/openai/v1/chat/completions':'https://api.openai.com/v1/chat/completions';
   headers.Authorization='Bearer '+key;
   payload={model,messages:[{role:'system',content:sys},{role:'user',content}],temperature:0.3};
 }
 const resp=await fetch(url,{method:'POST',headers,body:JSON.stringify(payload),signal:AbortSignal.timeout(90000)});
 const json=await resp.json();if(!resp.ok)throw Error(clip(json.error?.message||json.message||'Erro do provedor',250));
 return x.provider==='gemini'?json.candidates?.[0]?.content?.parts?.map(p=>p.text||'').join('\n'):x.provider==='ollama'?json.message?.content:json.choices?.[0]?.message?.content;
}
const mime={'.html':'text/html; charset=utf-8','.css':'text/css; charset=utf-8','.js':'text/javascript; charset=utf-8','.svg':'image/svg+xml'};
export const server=http.createServer(async(req,res)=>{
 try{
  if(!/^(localhost|127\.0\.0\.1|\[::1\])(:\d+)?$/i.test(req.headers.host||''))return send(res,403,{error:'Acesso somente localhost'});
  const u=new URL(req.url,'http://localhost');
  if(u.pathname.startsWith('/api/')){
    if(req.method!=='GET'&&!['http://127.0.0.1:'+port,'http://localhost:'+port].includes(req.headers.origin||''))return send(res,403,{error:'Origem proibida'});
    if(req.method==='GET'&&u.pathname==='/api/health')return send(res,200,{ok:true,app:'WMK CodeVerse Studio'});
    if(req.method==='GET'&&u.pathname==='/api/providers')return send(res,200,Object.entries(models).map(([id,v])=>({id,configured:id==='ollama'||Boolean(process.env[v[0]]),model:process.env[v[1]]||v[2]})));
    if(req.method==='GET'&&u.pathname==='/api/docs')return send(res,200,await readDocs());
    if(req.method==='POST'&&u.pathname==='/api/docs'){
      const x=await readBody(req),a=await readDocs();
      const item={id:clip(x.id,80)||crypto.randomUUID(),title:clip(x.title,120)||'Sem título',area:['2D','3D','Geral'].includes(x.area)?x.area:'Geral',language:clip(x.language,30)||'javascript',code:clip(x.code,200000),tags:clip(x.tags,300),updatedAt:new Date().toISOString()};
      const i=a.findIndex(v=>v.id===item.id);if(i<0)a.unshift(item);else a[i]=item;
      await saveDocs(a);return send(res,200,item);
    }
    if(req.method==='DELETE'&&u.pathname.startsWith('/api/docs/')){
      const id=decodeURIComponent(u.pathname.slice(10));await saveDocs((await readDocs()).filter(a=>a.id!==id));return send(res,200,{ok:true});
    }
    if(req.method==='POST'&&u.pathname==='/api/import'){
      const x=await readBody(req);if(!Array.isArray(x.docs)||x.docs.length>1000)throw Error('Biblioteca inválida');
      const a=x.docs.map(v=>({id:crypto.randomUUID(),title:clip(v.title,120),area:['2D','3D','Geral'].includes(v.area)?v.area:'Geral',language:clip(v.language,30),code:clip(v.code,200000),tags:clip(v.tags,300),updatedAt:new Date().toISOString()}));await saveDocs(a);return send(res,200,{ok:true,count:a.length});
    }
    if(req.method==='POST'&&u.pathname==='/api/ai'){const x=await readBody(req);if(!clip(x.prompt,24000).trim())return send(res,400,{error:'Digite sua pergunta'});return send(res,200,{reply:await ask(x)||'Sem resposta'});}
    return send(res,404,{error:'Rota não encontrada'});
  }
  if(!['GET','HEAD'].includes(req.method))return send(res,405,{error:'Método inválido'});
  const name=decodeURIComponent(u.pathname==='/'?'/index.html':u.pathname),full=path.resolve(pub,'.'+name);
  if(!full.startsWith(pub+path.sep))return send(res,403,{error:'Caminho proibido'});
  const buf=await fs.readFile(full);res.writeHead(200,{'Content-Type':mime[path.extname(full)]||'application/octet-stream','X-Content-Type-Options':'nosniff','Content-Security-Policy':"default-src 'self' https://cdn.jsdelivr.net; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; worker-src blob:; connect-src 'self' https://cdn.jsdelivr.net"});res.end(req.method==='HEAD'?undefined:buf);
 }catch(e){send(res,e.code==='ENOENT'?404:500,{error:e.code==='ENOENT'?'Arquivo não encontrado':clip(e.message,350)})}
});
if(process.env.NODE_ENV!=='test')server.listen(port,'127.0.0.1',()=>console.log('WMK CodeVerse Studio http://127.0.0.1:'+port));
