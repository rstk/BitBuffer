"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[331],{76647:function(e,t,n){n.r(t),n.d(t,{frontMatter:function(){return u},contentTitle:function(){return f},metadata:function(){return o},toc:function(){return s},default:function(){return m}});var r=n(87462),a=n(63366),l=(n(67294),n(3905)),i=["components"],u={},f="BitBuffer",o={type:"mdx",permalink:"/BitBuffer/",source:"@site/pages/index.md"},s=[{value:"Usage",id:"usage",children:[]},{value:"Docs",id:"docs",children:[]},{value:"Minimal tutorial",id:"minimal-tutorial",children:[]}],p={toc:s};function m(e){var t=e.components,n=(0,a.Z)(e,i);return(0,l.kt)("wrapper",(0,r.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,l.kt)("h1",{id:"bitbuffer"},"BitBuffer"),(0,l.kt)("p",null,"Blazing-fast BitBuffer for Roblox."),(0,l.kt)("h2",{id:"usage"},"Usage"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-lua"},'local ReplicatedStorage = game:GetService("ReplicatedStorage")\nlocal BitBuffer = require(ReplicatedStorage.Packages.BitBuffer)\n\nlocal PlayerData = {}\nPlayerData.__index = PlayerData\n\nfunction PlayerData.new(serialized: string?)\n    local buffer = BitBuffer.FromBase91(serialized or "")\n\n    return setmetatable({\n        Money = buffer:ReadUInt(32);\n        Experience = buffer:ReadUInt(16);\n        AverageFps = buffer:ReadFloat32();\n        CustomName = buffer:ReadString();\n    }, PlayerData)\nend\n\nfunction PlayerData:Serialize(): string\n    local buffer = BitBuffer.new()\n    buffer:WriteUInt(32, self.Money)\n    buffer:WriteUInt(16, self.Experience)\n    buffer:WriteFloat32(self.AverageFps)\n    buffer:WriteString(self.CustomName)\n\n    return buffer:ToBase91()\nend\n\nexport type PlayerData = typeof(PlayerData.new())\nreturn PlayerData\n')),(0,l.kt)("h2",{id:"docs"},"Docs"),(0,l.kt)("p",null,"Documentation can be found ",(0,l.kt)("a",{parentName:"p",href:"https://rstk.github.io/BitBuffer"},"here"),". Keep in mind this is work in progress."),(0,l.kt)("h2",{id:"minimal-tutorial"},"Minimal tutorial"),(0,l.kt)("p",null,"The available types are:"),(0,l.kt)("ul",null,(0,l.kt)("li",{parentName:"ul"},"UInt"),(0,l.kt)("li",{parentName:"ul"},"Int"),(0,l.kt)("li",{parentName:"ul"},"Bool"),(0,l.kt)("li",{parentName:"ul"},"Char"),(0,l.kt)("li",{parentName:"ul"},"Bytes"),(0,l.kt)("li",{parentName:"ul"},"String"),(0,l.kt)("li",{parentName:"ul"},"Float32"),(0,l.kt)("li",{parentName:"ul"},"Float64")),(0,l.kt)("p",null,"You can serialize the buffer into:"),(0,l.kt)("ul",null,(0,l.kt)("li",{parentName:"ul"},"String"),(0,l.kt)("li",{parentName:"ul"},"Base64"),(0,l.kt)("li",{parentName:"ul"},"Base91 (recommended for DataStores)"),(0,l.kt)("li",{parentName:"ul"},"Base128")),(0,l.kt)("p",null,"Using the methods ",(0,l.kt)("inlineCode",{parentName:"p"},"BitBuffer::ToString()"),", ",(0,l.kt)("inlineCode",{parentName:"p"},"BitBuffer::ToBase64()"),", ",(0,l.kt)("inlineCode",{parentName:"p"},"BitBuffer::ToBase91()")," and ",(0,l.kt)("inlineCode",{parentName:"p"},"BitBuffer::ToBase128()"),".  "),(0,l.kt)("p",null,"Create a new BitBuffer with one of the following constructors:"),(0,l.kt)("ul",null,(0,l.kt)("li",{parentName:"ul"},"new"),(0,l.kt)("li",{parentName:"ul"},"FromString"),(0,l.kt)("li",{parentName:"ul"},"FromBase64"),(0,l.kt)("li",{parentName:"ul"},"FromBase91"),(0,l.kt)("li",{parentName:"ul"},"FromBase128")),(0,l.kt)("p",null,"Write/Read methods are ",(0,l.kt)("inlineCode",{parentName:"p"},"buffer:Write<type name>"),"/",(0,l.kt)("inlineCode",{parentName:"p"},"buffer:Read<type name>"),".",(0,l.kt)("br",{parentName:"p"}),"\n","For example:"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-lua"},"buffer:WriteUInt(32, 1)\nbuffer:ReadString()\nbuffer:WriteBool(true)\n")),(0,l.kt)("p",null,"A BitBuffer has a cursor, indexed in bits, which increases every time something is written/read."),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-lua"},"local buffer = BitBuffer.new() -- The cursor's position is 0\nbuffer:WriteUInt(16, 1) --\x3e It's now 16\nbuffer:WriteFloat64() --\x3e It's now 80\nbuffer:ResetCursor() --\x3e It's now 0\nbuffer:ReadUInt(16) --\x3e It's now 16\n")),(0,l.kt)("p",null,"A BitBuffer also keeps track of its size."),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-lua"},"local buffer = BitBuffer.new() --\x3e Size is 0\nbuffer:WriteUInt(32, 80) --\x3e Size is 32\nbuffer:WriteFloat64() --\x3e Size is 96\nbuffer:ResetCursor() --\x3e Size is still 96\nbuffer:ReadUInt(32) --\x3e Size is still 96\nbuffer:ResetBuffer() --\x3e Size is now 0\n")),(0,l.kt)("p",null,"The rest of the methods are:"),(0,l.kt)("pre",null,(0,l.kt)("code",{parentName:"pre",className:"language-lua"},"buffer:ResetCursor(): ()\nbuffer:SetCursor(position: number): ()\nbuffer:GetCursor(): number\nbuffer:ResetBuffer(): ()\nbuffer:GetSize(): number\n")))}m.isMDXComponent=!0}}]);