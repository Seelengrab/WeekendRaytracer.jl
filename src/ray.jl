struct ray
    orig::point3
    dir::vec3
end
ray() = ray(point3(0,0,0), vec3(0,0,0))

origin(r::ray) = r.orig
direction(r::ray) = r.dir

at(r::ray, t::Real) = r.orig + t * r.dir
