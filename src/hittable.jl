mutable struct hit_record
    p::point3
    normal::vec3
    t::Float64
    front_face::Bool
end
hit_record() = hit_record(point3(0,0,0),vec3(0,0,0),-Inf,false)

Base.size(::hit_record) = (1,)
Base.broadcastable(x::hit_record) = x

function set_face_normal!(hr::hit_record, r::ray, outward_normal::vec3)
    hr.front_face = dot(direction(r), outward_normal) < 0
    hr.normal = hr.front_face ? outward_normal : -outward_normal
end

struct HitRecordStyle <: Base.Broadcast.BroadcastStyle end
Base.BroadcastStyle(::Type{hit_record}) = HitRecordStyle()
Base.similar(bc::Base.Broadcast.Broadcasted{HitRecordStyle}, ::Type{hit_record}) = hit_record()
function Base.copyto!(dest::hit_record, bc::Base.Broadcast.Broadcasted{HitRecordStyle})
    src = bc.args[1]
    dest.p = src.p
    dest.normal = src.normal
    dest.t = src.t
    dest.front_face = src.front_face
    dest
end

abstract type hittable end

"""
    hit(::hittable, ::ray, t_min::Real, t_max::Real, ::hit_record)

Returns whether or not the given `<: hittable` is hit by the given ray. Saves the resulting data in the given `hit_record`.
"""
function hit end
