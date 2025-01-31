package main

import "core:fmt"
import "core:strings"

import sdl "vendor:sdl2"
import sdl_image "vendor:sdl2/image"

Texture :: struct {
    texture : ^sdl.Texture,
    height : i32,
    width : i32,
}

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_background_texture : Texture
global_foo_texture : Texture
global_renderer : ^sdl.Renderer
global_window : ^sdl.Window

main :: proc() {

    if !init() {
        fmt.eprintln("Failed to init!")
        return
    }

    if !load_media() {
        fmt.eprintln("Failed to load_media")
        return
    }

    e : sdl.Event
    quit := false

    for !quit {
        for sdl.PollEvent(&e) {
            if e.type == sdl.EventType.QUIT {
                quit = true
            }
        }

        sdl.SetRenderDrawColor(global_renderer, 0xFF, 0xFF, 0xFF, 0xFF)
        sdl.RenderClear(global_renderer)
        texture_render(global_background_texture, 0, 0)
        texture_render(global_foo_texture, 240, 190)
        sdl.RenderPresent(global_renderer)
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    texture_free(&global_background_texture)
    texture_free(&global_foo_texture)
    sdl.DestroyRenderer(global_renderer)
    sdl.DestroyWindow(global_window)
    sdl_image.Quit()
    sdl.Quit()
}

init :: proc() -> bool {
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        fmt.eprintfln("SDL could not initialise! SDL_Error: %s", sdl.GetError())
        return false
    }

    if !sdl.SetHint(sdl.HINT_RENDER_SCALE_QUALITY, "1") {
        fmt.eprintln("Warning: Linear texture filtering not enabled!")
    }

    global_window = sdl.CreateWindow(
        "The Viewport",
        sdl.WINDOWPOS_UNDEFINED,
        sdl.WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        sdl.WINDOW_SHOWN
    )

    if global_window == nil {
        fmt.eprintfln("Could not create window. SDL_Error: %s", sdl.GetError())
        return false
    }

    global_renderer = sdl.CreateRenderer(global_window, -1, sdl.RENDERER_ACCELERATED)

    if global_renderer == nil {
        fmt.eprintfln("Renderer could not be created! SDL error: %s", sdl.GetError())
        return false
    }

    sdl.SetRenderDrawColor(global_renderer, 0xFF, 0xFF, 0xFF, 0xFF)

    if sdl_image.Init(sdl_image.INIT_PNG) & sdl_image.INIT_PNG != sdl_image.INIT_PNG {
        fmt.eprintfln("sdl_image could not be initialised. sdl_image error: %s", sdl_image.GetError())
        return false
    }

    return true
}

load_media :: proc() -> bool {
    if !texture_load_from_file(&global_background_texture, "./assets/background.png") {
        fmt.eprintln("Failed to load background texture image.")
        return false
    }

    if !texture_load_from_file(&global_foo_texture, "./assets/foo.png") {
        fmt.eprintln("Failed to load foo texture image.")
        return false
    }

    return true
}

texture_free :: proc(texture : ^Texture) {
    sdl.DestroyTexture(texture.texture)
    texture.texture = nil
    texture.height = 0
    texture.width = 0
}

texture_load_from_file :: proc(texture: ^Texture, file : string) -> bool {
    texture_free(texture)

    loaded_surface := sdl_image.Load(strings.clone_to_cstring(file))

    if loaded_surface == nil {
        fmt.eprintfln("Unable to load images %s! sdl_image error: %s", file, sdl_image.GetError())
        return false
    }

    sdl.SetColorKey(loaded_surface, 1, sdl.MapRGB(loaded_surface.format, 0, 0xFF, 0xFF))

    new_texture := sdl.CreateTextureFromSurface(global_renderer, loaded_surface)

    if new_texture == nil {
        fmt.eprintfln("Unable to create texture from %s! sdl error: %s", file, sdl.GetError())
        sdl.FreeSurface(loaded_surface)
        return false
    }

    texture.texture = new_texture
    texture.width = loaded_surface.w
    texture.height = loaded_surface.h

    sdl.FreeSurface(loaded_surface)

    return true
}

texture_render :: proc(texture : Texture, x : i32, y : i32) {
    render_quad := sdl.Rect {
        x = x,
        y = y,
        w = texture.width,
        h = texture.height
    }

    sdl.RenderCopy(global_renderer, texture.texture, nil, &render_quad)
}