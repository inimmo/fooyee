# Fooyee
_fouillis_, FR: A pile of disparate objects gathered together pell-mell

## What's This Then?
It's a base Pico 8 cart divided up into a bunch of helper functions and boilerplate code for inheritance, etc. It's generally what I use when I'm starting a new project.

Because even when I'm limited to 65kb, 16 colours and a 128x128 resolution, I still end up writing frameworks instead of programs.

## Features
### Inheritance
Basic mixin-style inheritance, by using the `extend` helper. This takes an object and a map of functions that should be added:

```lua
 man = {name="Arthur"}
 
 extend(man, {
  greet=function(o)
   print("Hello "..o.name)
  end 
 })
 
 man:greet()
 
 -- HELLO ARTHUR
```

Multiple extensions can be made to the same object, with the latter ones taking priority if any keys clash.

A `super()` helper function is also provided in order to allow augmenting the default implementation from any libraries. Building on the example above, adding
```lua
 man.greet = function(o)
  print("i am about to say hello")
  super(o,"greet")
 end
```

results in
```
I AM ABOUT TO SAY HELLO
HELLO ARTHUR
```

### Systems
A system is a set of related objects, designed to cut down on repeated `for x in all(sprites)...` loops

Two conventions are used: a `u` (update) method designed to be called in `_update()`, and `r` (render) designed to be used in `_draw()`. Systems can (and should) be nested, which means that a single call to a "world" system in the main methods will then flow down to all other nested objects.

Any object can be added to a system providing they support calling these two methods.

Child objects that return false from their update method are removed from the parent system. This allows short-lived systems (such as the particle helper method below), which are removed from the hierarchy when they have finished their job.

A variadic `s(...)` helper function is available to initialise systems, as well as a `system:add()` helper method to add child systems at runtime:
```lua
function _init()
 enemies = s()
 weather = s()
 world = s(enemies, weather)

 player = get_player()
 world:add(player)
end
```

### Vector Library
A very basic copy of some of the work in vector.p8 by ThaCuber (https://www.lexaloffle.com/bbs/?tid=50410), but with a slightly more OO approach.

Provides add/sub/mul/div/neg/mag/norm methods, a helper factory function `v(x,y)`, and allows chaining calls:
```lua
> print(v(2,3):mul(2):neg())
{-4,-6}
> print(v(1,1):mag())
1.4142
> print(v(1,1):norm())
{0.7071,0.7071}
 ```

Operator overloads are also provided
```lua
> print(v(1,1) + v(2,2))
{3,3}
```

### Physics
A simple physics process is included as an extension library, providing a way to trivially interpolate two vectors to generate a new position.

An object can use this library by calling `extend(obj,physics)`, which will expose a `u` implementation designed to be used in a System (above). This simply adds the object's `d` (delta) vector to its current `p` (position) vector and applies a gravity vector. This vector is available for runtime modification using `physics.g`. Gravity is applied to both axes, which allows simulating wind (or similar), 

A helper function `body(position,delta)` is provided, which will return a basic physics object that implements the render and physics libraries.

TODO:
* Anything to do with collision detection, friction, dampening (i.e actual "physics")

### Rendering
This extension library currently makes a lot of assumptions about naming:

| Name | Behaviour                                                                                                     |
|------|---------------------------------------------------------------------------------------------------------------|
| x,y  | Position in pixels                                                                                            |
| p    | Alternatively, position as a vector                                                                           |
| c    | A colour palette index, which will override any white pixels in the result. For a sprite, flag 4 must be set. |
| s    | A sprite index                                                                                                |
| f    | Whether to flip the sprite along the horizontal axis                                                          |

By default, an object using this render method will display a single white pixel at the provided coordinates.

TODO:
* A specific flag shouldn't be responsible for the sprite/palette switch behaviour, but I haven't found a pattern I like
* Doesn't support vertical flipping (and therefore doesn't support rotation). Not hard to add, but needs even more magic variable names or values.
* No support for rectfill/circfill/etc, it's either single-pixel or full sprite

### Particles
A wrapper for a particle system is provided both as utility and a basic example of how to create a custom system. Specifically here, a particle system always has a finite lifetime; after this frame the system returns false. This is done by overriding the default update function to check a frame counter, and delegate to the parent implementation only until the lifetime is reached.

Calling `particle(origin,count,lifetime,factory)` will return a system containing _count_ elements, each created using the callback _factory_. The factory callback is passed the _origin_ vector and the iteration up to the maximum of _count_.

The simplest implementation of a factory method would be to delegate to `body(origin)`. By default, this would create a single physics body at the origin point (which will then fall off the screen, assuming default gravity). A basic glitter bomb might look like this:
```lua
particle(
  v(64,64),
  100,
  60,
  function(o,i)
   local b = body(o)
   b.c = rnd(15)+1
   b.d = v(rnd(8)-4,rnd(16)-8)
   return b
  end
 )
```

This would create 100 physics bodies with random velocities and colours at the centre of the screen. After 60 frames, the system will die.

Adding the `s` property in the factory would use a sprite instead of a single pixel.

## A Very Simple Example
```lua
-- Define our world and add a system to manage the rain
function _init()
 rain = s()
 world = s(rain)
end

-- Each frame, add a raindrop to a random position along row 8
function _update()
 rain:add(body(
  v(rnd(112)+8,8)
 ))
 
 world:u()
end

-- Render world system
function _draw()
 cls()
 world:r()
end
```

The immediate problem here is that the raindrops don't ever die, so we very quickly hit a memory limit. A simple fix is to add a custom update function that returns false when the drop is off the screen:

```lua
local drop = body(
 v(rnd(112)+8,8)
)

drop.u = function(b)
 super(b,"u")
 return b.p.y <= 127
end

rain:add(drop)
```

A generalised version of the function could also be written to always destroy physics bodies that are off any side of the screen.

### 
