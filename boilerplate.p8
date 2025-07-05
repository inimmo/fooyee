pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
 rain = s()
 world = s(rain)
end

function _update()
 rain:add(body(
  v(rnd(112)+8,8)
 ))
 
 world:u()
end

function _draw()
 cls()
 world:r()
end
-->8
--systems and inheritance
function extend(p,tbl)
 local mt = getmetatable(p)
   or {}
 
 setmetatable(p, mt)

 local prev = mt.__index
  or
  function() end

 mt.__index = function(t, k)
   return tbl[k] or prev(t, k)
 end
 
 return p
end

function super(p, m)
 return getmetatable(p)
   .__index(p,m)(p)
end

system = {
 add = function(s, e)
  add(s.c, e)
 end,
 
 u = function(s)
  for e in all(s.c) do
   if (not e:u()) del(s.c, e)
  end
  
  return #s.c > 0
 end,
 
 r = function(s)
  for e in all(s.c) do
   e:r()
  end
 end,
}

function s(...)
 return extend({c={...}},system)
end

function merge(t,n)
 for k,v in pairs(n) do
  t[k] = v
 end
 
 return t
end

-->8
--vectors
vec = {}

function vec._(x, y)
 local r = {
  x = x,
  y = y,

  add = function(_ENV, a)
   return v(x + a.x, y + a.y)
  end,

  sub = function(_ENV, a)
   return v(x, y) + a:neg()
  end,

  neg = function(_ENV)
   return v(-x, -y)
  end,

  mul = function(_ENV, n)
   return v(x * n, y * n)
  end,

  div = function(_ENV, n)
   return v(x, y) * (1/n)
  end,

  mag = function(_ENV)
   return (x ^ 2 + y ^ 2) ^ 0.5
  end,

  norm = function(_ENV)
   return div(_ENV, mag())
  end,
 }

 mt={
   __index={v=function(x,y)return v(x,y)end},
   __tostring=function(v)return"{"..v.x..","..v.y.."}"end
 }

 for s in all{"add","sub","mul","div"} do
  mt["__"..s]=function(a,b)return a[s](a,b)end
 end

 return setmetatable(r,mt)
end

v=function(x,y)return vec._(x,y)end

-->8
--physics
physics = {
 g = v(0,0.35),
 
 gr=function(p)
  p.d.x += p.g.x * p.m
  p.d.y += p.g.y * p.m
 end,
 
 u=function(p)
  p:gr()
  
  p.p = p.p:add(p.d)
  
  return true
 end
}

function body(p,d,m)
 local b={
  p=p,
  m=m or 1,
  d=d or v(0,0)
 }

 extend(b,render)
 extend(b,physics)

 b.r=function(b)
  b.x = b.p.x
  b.y = b.p.y
  
  super(b,"r")
 end
 
 return b
end

-->8
--rendering
render = {
 r = function(r)
  local x = r.x or r.p.x
  local y = r.y or r.p.y
  
  if (r.s and fget(r.s,4)) then
   pal(7,r.c or 7)
   spr(r.s,x,y,1,1,r.f)
   pal()
  elseif (r.s) then
   spr(r.s,x,y,1,1,r.f)
  else
   pset(x,y,r.c or 7)
  end
 end
}

-->8
--particles
function particle(o,n,l,f)
 local p = s()
 p.t = 0
 
 for i=1,n do
  p:add(f(o,i))
 end
 
 p.u = function(p)
  p.t += 1
  
  if (p.t > l) return false
  
  return super(p,"u")
 end
 
 return p
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
