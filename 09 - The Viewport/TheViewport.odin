package main

import "core:fmt"
import "core:strings"

import sdl "vendor:sdl2"
import sdl_image "vendor:sdl2/image"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_renderer : ^sdl.Renderer
global_texture : ^sdl.Texture
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
        // Top left corner viewport
        top_left_viewport := sdl.Rect {
            x = 0,
            y = 0,
            w = SCREEN_WIDTH / 2,
            h = SCREEN_HEIGHT / 2
        }
        sdl.RenderSetViewport(global_renderer, &top_left_viewport)
        sdl.RenderCopy(global_renderer, global_texture, nil, nil)
        // Top right viewport
        top_right_viewport := sdl.Rect {
            x = SCREEN_WIDTH / 2,
            y = 0,
            w = SCREEN_WIDTH / 2,
            h = SCREEN_HEIGHT /2
        }
        sdl.RenderSetViewport(global_renderer, &top_right_viewport)
        sdl.RenderCopy(global_renderer, global_texture, nil, nil)
        // Bottom viewport
        bottom_viewport := sdl.Rect {
            x = 0,
            y = SCREEN_HEIGHT / 2,
            w = SCREEN_WIDTH,
            h = SCREEN_HEIGHT / 2
        }
        sdl.RenderSetViewport(global_renderer, &bottom_viewport)
        sdl.RenderCopy(global_renderer, global_texture, nil, nil)

        sdl.RenderPresent(global_renderer)
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    sdl.DestroyRenderer(global_renderer)
    sdl.DestroyTexture(global_texture)
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
    global_texture = load_texture("./assets/viewport.png")

    if global_texture == nil {
        fmt.eprintln("Failed to load texture image.")
        return false
    }

    return true
}

load_texture :: proc(texture : string) -> ^sdl.Texture {
    loaded_surface := sdl_image.Load(strings.clone_to_cstring(texture))

    if loaded_surface == nil {
        fmt.eprintfln("Unable to load images %s! sdl_image error: %s", texture, sdl_image.GetError())
        return nil
    }

    new_texture := sdl.CreateTextureFromSurface(global_renderer, loaded_surface)

    if new_texture == nil {
        fmt.eprintfln("Unable to create texture from %s! sdl error: %s", texture, sdl.GetError())
    }

    sdl.FreeSurface(loaded_surface)

    return new_texture
}