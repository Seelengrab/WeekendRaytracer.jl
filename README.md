# WeekendRaytracer.jl

This is a (somewhat) naive implementation of [Raytracing in a Weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
in pure julia. The first book is implemented in pure julia, no external libs required.

The second book, [RayTracing: The Next Week](https://raytracing.github.io/books/RayTracingTheNextWeek.html) (from tags `nextweek_*` onward) is mostly pure `Base`, but relies on `FileIO`
and `ImageIO` for reading/writing textures. This is also how PNG support is implemented.

## Additional Features

These are different from the original book, either because they couldn't be just used,
they shouldn't be implemented like in the book because of a better/more composable
API being available or because it's fun to optimize thing.

 * Threaded outermost loop
 * Type-safe iteration over different collision objects
   * This is accomplished via a `Dict{Type{<:hittable}, Vector{<:hittable}}`
 * Using the `Random.Sampler` API for generation of e.g. vectors in a unit disk
   * Check `src/vec3.jl` for the various functions!

## Using this

This is mostly done for fun. It's not supposed to be used for anything serious,
which is why there is no `LICENSE` file. It wouldn't feel right to have one for an implementation
of a public domain book. I mostly did this for educational purposes :)

I did allow for one convenience though - there are tags for each chapter of the original book that had
some kind of testable/comparable new result, with additional features directly on `master` (threading & type safety).

If you want to play around with this, clone this and either run `JULIA_NUM_THREADS = <your #cores> ./run.jl`
or run `julia --project` in this directory followed by `using WeekendRaytracer`. The default output directory is `./out`,
with the default file name being `image_small.png`.
