abstract type material end

"""
    scatter(m::material, r_in::ray) -> Tuple{Bool, ray, color}
"""
function scatter end

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
