"use strict";
const fs=require("node:fs");const path=require("node:path");const sharp=require("sharp");
const root=process.argv[2],logo=process.argv[3];
if(!root||!logo)throw Error("Uso: node brand-assets.cjs engine_root logo_svg");
const svg=fs.readFileSync(logo);
async function build(){
const image=(s)=>sharp(svg,{density:240}).resize(s,s,{fit:"contain"});
for(const [file,size] of [["icon.png",256],["icon_outlined.png",256],["logo.png",620],["logo_outlined.png",620],["main/app_icon.png",256]]){
  await image(size).png().toFile(path.join(root,file));
}
const title=`<svg width="1220" height="250" xmlns="http://www.w3.org/2000/svg"><style>text{font-family:Arial,sans-serif}</style><text x="0" y="115" font-size="105" font-weight="bold" fill="#ffffff">WMK CodeVerse</text><text x="2" y="183" font-size="35" fill="#5cecff">Engine • IA • Multilinguagem</text><text x="2" y="232" font-size="23" fill="#b7bbd9">Walney Moreira Klein — walneyk@hotmail.com</text></svg>`;
const badge=await image(610).png().toBuffer();
const bg=sharp({create:{width:1920,height:1080,channels:4,background:"#0b1024"}});
await bg.composite([{input:badge,left:165,top:220},{input:Buffer.from(title),left:785,top:390}]).png().toFile(path.join(root,"main/splash.png"));
const png=await image(256).png().toBuffer();
const header=Buffer.alloc(22);header.writeUInt16LE(0,0);header.writeUInt16LE(1,2);header.writeUInt16LE(1,4);header[6]=0;header[7]=0;header[8]=0;header[9]=0;header.writeUInt16LE(1,10);header.writeUInt16LE(32,12);header.writeUInt32LE(png.length,14);header.writeUInt32LE(22,18);
for(const name of ["godot.ico","godot_console.ico"])fs.writeFileSync(path.join(root,"platform/windows",name),Buffer.concat([header,png]));
console.log("WMK png, splash e icones .ico gerados a partir da logo oficial");
}
build().catch(e=>{console.error(e);process.exit(1)});
