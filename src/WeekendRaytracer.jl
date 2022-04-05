module WeekendRaytracer

using Base.Threads
using Dates
using Random

include("vec3.jl")
include("color.jl")
include("ray.jl")
include("camera.jl")
include("material.jl")
include("hittable.jl")
include("hittable_list.jl")
include("sphere.jl")
include("main.jl")

end # module WeekendRaytracer
