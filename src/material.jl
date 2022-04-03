abstract type material end

"""
    scatter(m::material, r_in::ray) -> Tuple{Bool, ray, color}
"""
function scatter end


####
# Solid Color
###

struct lambertian <: material
    albedo::color
end

function scatter(mat::lambertian, _, rec)
    scatter_direction = rec.normal + rand(UnitVector())

    # Catch degenerate scatter direction
    if near_zero(scatter_direction)
        scatter_direction = rec.normal
    end

    scattered = ray(rec.p, scatter_direction)
    attenuation = mat.albedo
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
    scattered = ray(rec.p, reflected + mat.fuzz * rand(InUnitSphere()))
    attenuation = mat.albedo
    scat = dot(direction(scattered), rec.normal) > 0
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

    scattered = ray(rec.p, dir)
    return true, scattered, attenuation
end

function reflectance(cosine::Float64, ref_idx::Float64)
    # Schlick's approximation for reflectance
    r0 = (1-ref_idx) / (1+ref_idx)
    r0 *= r0
    return r0 + (1-r0)*(1-cosine)^5
end
