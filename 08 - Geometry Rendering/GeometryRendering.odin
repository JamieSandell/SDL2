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

        sdl.SetRenderDrawColor(global_renderer, 0xFF, 0xFF, 0xFF, 0xFF)
        sdl.RenderClear(global_renderer)
        // Red filled quad
        sdl.SetRenderDrawColor(global_renderer, 0xFF, 0x00, 0x00, 0xFF)
        fill_rect : sdl.Rect = {
            x = SCREEN_WIDTH / 4,
            y = SCREEN_HEIGHT / 4,
            w = SCREEN_WIDTH / 2,
            h = SCREEN_HEIGHT / 2
        }
        sdl.RenderFillRect(global_renderer, &fill_rect)
        // Green outlined quad
        sdl.SetRenderDrawColor(global_renderer, 0x00, 0xFF, 0x00, 0xFF)
        outline_rect : sdl.Rect = {
            x = SCREEN_WIDTH / 6,
            y = SCREEN_HEIGHT / 6,
            w = SCREEN_WIDTH * 2 / 3,
            h = SCREEN_HEIGHT * 2 /3
        }
        sdl.RenderDrawRect(global_renderer, &outline_rect)
        // Blue horizontal line
        sdl.SetRenderDrawColor(global_renderer, 0x00, 0x00, 0xFF, 0xFF)
        sdl.RenderDrawLine(global_renderer, 0, SCREEN_HEIGHT / 2, SCREEN_WIDTH, SCREEN_HEIGHT /2)
        // Vertical line of yellow dots
        sdl.SetRenderDrawColor(global_renderer, 0xFF, 0xFF, 0x00, 0xFF)

        for y : i32 = 0; y < SCREEN_HEIGHT; y += 4 {
            sdl.RenderDrawPoint(global_renderer, SCREEN_WIDTH / 2, y)
        }

        sdl.RenderPresent(global_renderer)
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    sdl.DestroyRenderer(global_renderer)
    sdl.DestroyWindow(global_window)
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
        "Geometry Rendering",
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

    return true
}