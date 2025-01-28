package main

import "core:fmt"
import "core:strings"

import sdl "vendor:sdl2"
import sdl_image "vendor:sdl2/image"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_current_surface : ^sdl.Surface
global_screen_surface : ^sdl.Surface
global_stretched_surface : ^sdl.Surface
global_window : ^sdl.Window

main :: proc() {

    if !init() {
        fmt.eprintln("Failed to init!")
        return
    }

    global_stretched_surface = load_surface("./assets/loaded.png")

    if global_stretched_surface == nil {
        fmt.eprintln("Failed to load surface!")
        return
    }

    stretch_rect := sdl.Rect {
        x = 0,
        y = 0,
        w = SCREEN_WIDTH,
        h = SCREEN_HEIGHT
    }
    e : sdl.Event
    quit := false

    for !quit {
        for sdl.PollEvent(&e) {
            if e.type == sdl.EventType.QUIT {
                quit = true
            }
        }
        
        sdl.BlitScaled(global_stretched_surface, nil, global_screen_surface, &stretch_rect)
        sdl.UpdateWindowSurface(global_window)
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
        "Loading PNGs with SDL_image",
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

    global_screen_surface = sdl.GetWindowSurface(global_window)

    return true
}

load_surface :: proc(path : string) -> ^sdl.Surface {
    loaded_surface := sdl_image.Load(strings.clone_to_cstring(path))

    if loaded_surface == nil {
        fmt.eprintfln("Unable to load image %s! SDL error: %s", loaded_surface, sdl_image.GetError())
        return loaded_surface
    }

    optimised_surface := sdl.ConvertSurface(loaded_surface, global_screen_surface.format, 0)

    if optimised_surface == nil {
        fmt.eprintfln("Unable to optimise image %s! SDL error: %s", optimised_surface, sdl.GetError())
        return optimised_surface
    }

    sdl.FreeSurface(loaded_surface)

    return optimised_surface
}