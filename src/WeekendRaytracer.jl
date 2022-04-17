module WeekendRaytracer

import FileIO
import ImageIO
# necessary to prevent worldage issues?
import ColorTypes
# exclusively for final conversion when writing
using FixedPointNumbers: N0f8

using Base.Threads
using Dates
using Random

include("vec3.jl")
include("perlin.jl")
include("color.jl")
include("ray.jl")
include("camera.jl")
include("texture.jl")
include("material.jl")
include("aabb.jl")
include("hittable.jl")
include("bvh.jl")
include("hittable_list.jl")
include("sphere.jl")
include("moving_sphere.jl")
include("aarect.jl")
include("box.jl")
include("main.jl")

end # module WeekendRaytracer
