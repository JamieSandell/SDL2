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

global_renderer : ^sdl.Renderer
global_sprite_clips : [4]sdl.Rect
global_sprite_sheet_texture : Texture
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

        texture_render(global_sprite_sheet_texture, 0, 0, &global_sprite_clips[0]) // Top left
        texture_render(global_sprite_sheet_texture, SCREEN_WIDTH - global_sprite_clips[1].w, 0, &global_sprite_clips[1]) // Top right
        texture_render(global_sprite_sheet_texture, 0, SCREEN_HEIGHT - global_sprite_clips[2].h, &global_sprite_clips[2]) // Bottom left
        texture_render(global_sprite_sheet_texture, SCREEN_WIDTH - global_sprite_clips[3].w, SCREEN_HEIGHT - global_sprite_clips[3].h, &global_sprite_clips[3]) // Bottom right

        sdl.RenderPresent(global_renderer)
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    texture_free(&global_sprite_sheet_texture)
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
        "Clip Rendering and Sprite Sheets",
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
    if !texture_load_from_file(&global_sprite_sheet_texture, "./assets/dots.png") {
        fmt.eprintln("Failed to load dots texture image.")
        return false
    }

    global_sprite_clips[0].x = 0
    global_sprite_clips[0].y = 0
    global_sprite_clips[0].w = 100
    global_sprite_clips[0].h = 100

    global_sprite_clips[1].x = 100
    global_sprite_clips[1].y = 0
    global_sprite_clips[1].w = 100
    global_sprite_clips[1].h = 100

    global_sprite_clips[2].x = 0
    global_sprite_clips[2].y = 100
    global_sprite_clips[2].w = 100
    global_sprite_clips[2].h = 100

    global_sprite_clips[3].x = 100
    global_sprite_clips[3].y = 100
    global_sprite_clips[3].w = 100
    global_sprite_clips[3].h = 100

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

texture_render :: proc(texture : Texture, x : i32, y : i32, clip : ^sdl.Rect) {
    render_quad := sdl.Rect {
        x = x,
        y = y,
        w = texture.width,
        h = texture.height
    }

    if clip != nil {
        render_quad.w = clip.w
        render_quad.h = clip.h
    }

    sdl.RenderCopy(global_renderer, texture.texture, clip, &render_quad)
}