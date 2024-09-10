#define BASKET_PLATFORM
#include "../basket/basket.h"

static int init(void *userdata) {
    // Please refeer to basket/documentation/filesystem.md
    if (pak_mount("package/"))
        err_fatal("Filesystem", "Couldn't access filesystem!");

    size_t size;
    char *mem = pak_read("tex_atlas.png", &size);

    if (mem == 0)
        err_fatal("App", "Can't load atlas texture!");

    Texture texture = ren_tex_load(mem, size);

    ren_tex_bind(texture, 0);

    ren_videomode(256, 256, 0);
    eng_tickrate(6);

    return 0;
}

static int animation_frame = 0;

static int tick(void *userdata, f64 time) {
    animation_frame++;
    return 0;
}

static int frame(void *userdata, f64 alpha, f64 delta) {
    static TextureSlice animation[] = {
        { 16, 0, 32, 32 },
        { 48, 0, 32, 32 },
        { 16, 0, 32, 32 },
        { 80, 0, 32, 32 },
    };

    ren_quad((Quad) {
       .position = { -32, -32 },
       .scale = { 2, 2 },
       .texture = animation[animation_frame % 4],
       .color = COLOR_WHITE
    });

    return 0;
}

static Application app = {
    .userdata = 0,
    .init = init,
    .tick = tick,
    .frame = frame,
    .close = 0
};

int main() {
    return eng_main(app, false);
}
