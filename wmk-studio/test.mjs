import {test} from 'node:test';
import assert from 'node:assert/strict';
process.env.NODE_ENV='test';
const {server}=await import('./server.mjs');
test('Servidor e biblioteca locais',async()=>{
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  const port=server.address().port;
  try{
    const r=await fetch('http://127.0.0.1:'+port+'/api/health');
    assert.equal(r.status,200);
    assert.equal((await r.json()).ok,true);
    const html=await fetch('http://127.0.0.1:'+port+'/');
    assert.equal(html.status,200);
  }finally{
    await new Promise(resolve=>server.close(resolve));
  }
});
