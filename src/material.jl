abstract type material end

"""
    scatter(m::material, r_in::ray) -> Tuple{Bool, ray, color}

Scatters the incoming ray according to the given material.

Returns whether the ray was scattered (and thus `ray` is valid) and if so which color it scattered as.
"""
function scatter end

"""
    emitted(::material, u::Float64, v::Float64, p::point3) -> color

Returns the color emitted by a material at the given point & uv.

If not implemented, returns `color(0.0, 0.0, 0.0)` by default.
"""
function emitted(::material, u::Float64, v::Float64, p::point3)
    return color(0.0, 0.0, 0.0)
end

####
# Solid Color
###

struct lambertian{T<:texture} <: material
    albedo::T
end
lambertian(a::color) = lambertian(solid_color(a))

function scatter(mat::lambertian, r_in::ray, rec)
    scatter_direction = rec.normal + rand(UnitVector())

    # Catch degenerate scatter direction
    if near_zero(scatter_direction)
        scatter_direction = rec.normal
    end

    scattered = ray(rec.p, scatter_direction, time(r_in))
    attenuation = value(mat.albedo, rec.u, rec.v, rec.p)
    return true, scattered, attenuation
end

####
# Metal/Shiny
####

struct metal <: material
    albedo::color
    fuzz::Float64
    metal(c::color, f::Float64) = new(c, min(f, 1.0))
end

function scatter(mat::metal, r_in::ray, rec)
    reflected = reflect(unit_vector(direction(r_in)), rec.normal)
    scattered = ray(rec.p, reflected + mat.fuzz * rand(InUnitSphere()), time(r_in))
    attenuation = mat.albedo
    scat = dot(direction(scattered), rec.normal) > 0.0
    return scat, scattered, attenuation
end

####
# Dielectric/Glassy
####

struct dielectric <: material
    ir::Float64
end

function scatter(mat::dielectric, r_in::ray, rec)
    attenuation = color(1,1,1)
    refraction_ratio = rec.front_face ? (1.0/mat.ir) : mat.ir

    unit_direction = unit_vector(direction(r_in))
    cos_theta = min(dot(-unit_direction, rec.normal), 1.0)
    sin_theta = sqrt(1.0 - cos_theta*cos_theta)

    cannot_refract = refraction_ratio * sin_theta > 1.0
    dir = if cannot_refract || reflectance(cos_theta, refraction_ratio) > rand(Float64)
        reflect(unit_direction, rec.normal)
    else
        refract(unit_direction, rec.normal, refraction_ratio)
    end

    scattered = ray(rec.p, dir, time(r_in))
    return true, scattered, attenuation
end

function reflectance(cosine::Float64, ref_idx::Float64)
    # Schlick's approximation for reflectance
    r0 = (1-ref_idx) / (1+ref_idx)
    r0 *= r0
    return r0 + (1-r0)*(1-cosine)^5
end

#####
# diffuse light
#####

struct diffuse_light{T <: texture} <: material
    emit::T
end
diffuse_light(c::color) = diffuse_light(solid_color(c))

function scatter(::diffuse_light, _, _)
    return false, vec3(0,0,0), color(0,0,0)
end

function emitted(dl::diffuse_light, u::Float64, v::Float64, p::point3)
    value(dl.emit, u, v, p)
end

#####
# isotropic
#####

struct isotropic{T <: texture} <: material
    albedo::T
end
isotropic(c::color) = isotropic(solid_color(c))

function scatter(i::isotropic, r_in::ray, rec)
    scat = ray(rec.p, rand(InUnitSphere()), time(r_in))
    att = value(i.albedo, rec.u, rec.v, rec.p)
    return true, scat, att
end
