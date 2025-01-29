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

    e : sdl.Event
    quit := false

    for !quit {
        for sdl.PollEvent(&e) {
            if e.type == sdl.EventType.QUIT {
                quit = true
            }
        }
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    sdl.DestroyWindow(global_window)
    sdl.FreeSurface(global_stretched_surface)
    sdl.Quit() // frees the memory for the main window surface along with calling various subsystem Quits.
}

init :: proc() -> bool {
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        fmt.eprintfln("SDL could not initialise! SDL_Error: %s", sdl.GetError())
        return false
    }

    global_window = sdl.CreateWindow(
        "Texture Loading and Rendering",
        sdl.WINDOWPOS_UNDEFINED,
        sdl.WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        sdl.WINDOW_SHOWN
    )

    if global_window == nil {
        fmt.eprintfln("Could not create window. SDL_Error: %s", sdl.GetError())
        return false
    }

    if (sdl_image.Init(sdl_image.INIT_PNG) & sdl_image.INIT_PNG) != sdl_image.INIT_PNG{
        fmt.eprintfln("sdl_image could not initialise! SDL_Image error: %s", sdl_image.GetError())
        return false
    }

    sdl.SetRenderDrawColor(global_renderer, 0xFF, 0xFF, 0xFF, 0xFF)

    return true
}

load_texture :: proc(path : string) -> ^sdl.Texture {
    loaded_surface := sdl_image.Load(strings.clone_to_cstring(path))

    if loaded_surface == nil {
        fmt.eprintfln("Unable to load image %s! SDL_image error: %s", path, sdl_image.GetError())
        return nil
    }

    new_texture := sdl.CreateTextureFromSurface(global_renderer, loaded_surface)

    if new_texture == nil {
        fmt.eprintfln("Unable to create texture from %s! SDL error: %s", path, sdl.GetError())
        return nil
    }

    sdl.FreeSurface(loaded_surface)

    return new_texture
}