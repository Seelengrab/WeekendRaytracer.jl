struct ray
    orig::point3
    dir::vec3
    tm::Float64
end
ray(orig::point3, dir::vec3) = ray(orig, dir, 0.0)
ray() = ray(point3(0,0,0), vec3(0,0,0), 0.0)

origin(r::ray) = r.orig
direction(r::ray) = r.dir
time(r::ray) = r.tm

at(r::ray, t::Real) = r.orig + t * r.dir
