local ffi = require"ffi"

--from https://github.com/sonoro1234/LuaJIT-SDL2
local sdl = require"sdl2_ffi"
--just to get gl functions
-- from https://github.com/sonoro1234/LuaJIT-GLFW
local gllib = require"gl"
gllib.set_loader(sdl)
local gl, glc, glu, glext = gllib.libraries()

local ig = require"imgui.sdl"

if (sdl.init(sdl.INIT_VIDEO+sdl.INIT_TIMER+sdl.INIT_GAMECONTROLLER) ~= 0) then
  print(string.format("Error: %s\n", sdl.getError()));
  return -1;
end

    sdl.gL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE);
    sdl.gL_SetAttribute(sdl.GL_DOUBLEBUFFER, 1);
    sdl.gL_SetAttribute(sdl.GL_DEPTH_SIZE, 24);
    sdl.gL_SetAttribute(sdl.GL_STENCIL_SIZE, 8);
    sdl.gL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 3);
    sdl.gL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 1);
    local current = ffi.new("SDL_DisplayMode[1]")
    sdl.getCurrentDisplayMode(0, current);
    local window = sdl.createWindow("ImGui SDL2+OpenGL3 example", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 720, 640, sdl.WINDOW_OPENGL+sdl.WINDOW_RESIZABLE); 
    local gl_context = sdl.gL_CreateContext(window);
    sdl.gL_SetSwapInterval(1); -- Enable vsync
    
    local ig_Impl = ig.Imgui_Impl_SDL_opengl3()
    
    ig_Impl:Init(window, gl_context)

    local igio = ig.GetIO()
    igio.ConfigFlags = ig.lib.ImGuiConfigFlags_NavEnableKeyboard + igio.ConfigFlags 
    -- igio.ConfigFlags = ig.lib.ImGuiConfigFlags_NavEnableGamepad + igio.ConfigFlags
    
    -- For R36S
    -- local remap = "1900c3ea010000000100000001010000,odroidgo3_joypad,a:b1,b:b0,dpdown:b13,dpleft:b14,+lefty:+a1,-leftx:-a0,+leftx:+a0,-lefty:-a1,leftshoulder:b4,leftstick:b16,lefttrigger:b6,dpright:b15,+righty:+a3,-rightx:-a2,+rightx:+a2,-righty:-a3,rightshoulder:b5,rightstick:b10,righttrigger:b7,back:b8,start:b9,dpup:b12,x:b2,y:b3,guide:b11,platform:Linux"
    -- local res = sdl.SDL_GameControllerAddMapping(remap)
    local ffi = require("ffi")
    ffi.cdef[[
      typedef unsigned char stbi_uc;
      stbi_uc *stbi_load(char const *filename, int *x, int *y, int *comp, int req_comp);
    ]]
    -- local lunasvg = ffi.load("build/pfx/lib/liblunasvg.so")
    local stbi = ffi.load("/tmp/stb/stb_image.so")
    local x = ffi.new("int[1]")
    local y = ffi.new("int[1]")
    local comp = ffi.new("int[1]")
    -- local reqcomp = ffi.new("int[1]")

    local bitmap = stbi.stbi_load("/home/xox/Sync/SyncMore/lua/foo.png", x, y, comp, 4)
    print("hello ", x[0], y[0], comp[0])
    
    
    function checkErr()
      local err = gl.glGetError()
      if(err ~= glc.GL_NO_ERROR) then
        print("Error!")
      end
    end
    
    logo_tex = ffi.new("GLuint[1]")
    gl.glGenTextures(1, logo_tex);
    checkErr()
    gl.glBindTexture(glc.GL_TEXTURE_2D, logo_tex[0]);
    checkErr()
    
    local image_height = y[0];
    local image_width = x[0];
    
    -- local bitmap = ffi.new("uint32_t[256][256]")
    -- for p_y=0,255 do
      -- for p_x=0,255 do
        -- print(p_x, p_y)
        -- if (p_x % 2 == 0) then bitmap[p_x][p_y] = 0xff00ffff
        -- else bitmap[p_x][p_y] = 0xffffffff end
    --     bitmap[p_x][p_y] = p_x + p_y * 4
    --   end
    -- end
    -- for p_y=0,255 do
    --   for p_x=0,255 do
    --     print(p_x, p_y, bitmap[p_x][p_y])
    --   end
    -- end;;
    
    gl.glTexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MIN_FILTER, glc.GL_LINEAR);
    checkErr()
    gl.glTexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_MAG_FILTER, glc.GL_LINEAR);
    checkErr()
    gl.glTexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_S, glc.GL_CLAMP_TO_EDGE); -- This is required on WebGL for non power-of-two textures
    checkErr()
    gl.glTexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_T, glc.GL_CLAMP_TO_EDGE); -- Same
    checkErr()
    -- gl.glTexParameteri(glc.GL_TEXTURE_2D, glc.GL_GENERATE_MIPMAP, glc.GL_FALSE);
    -- gl.glTexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_S, glc.GL_REPEAT);
    -- gl.glTexParameteri(glc.GL_TEXTURE_2D, glc.GL_TEXTURE_WRAP_T, glc.GL_REPEAT);
    gl.glPixelStorei(glc.GL_UNPACK_ROW_LENGTH, 0);
    checkErr()
    gl.glTexImage2D(glc.GL_TEXTURE_2D, 0, glc.GL_RGBA, image_width, image_height, 0, glc.GL_RGBA, glc.GL_UNSIGNED_BYTE, bitmap);
    checkErr()
    
    print("Gluint tex ", logo_tex[0])
    
    print"bar"
    local yes_i = false
    if yes_i ~= true then
      -- local pixels = ffi.new("uint8_t[?]", 512*512*4)
      -- gl.glGetTexImage(glc.GL_TEXTURE_2D, 0, glc.GL_RGBA, glc.GL_UNSIGNED_BYTE, pixels);
      -- for i=0,(512*512*4)-1 do
      --   print(pixels[i])
      -- end
      yes_i = true
    end
    print"baz"
    
    local my_tex_id = ffi.new("ImTextureID[1]", igio.Fonts.TexID)
    print("ImTextureID fonts texid: ", my_tex_id[0])
    
    local done = false;
    local showdemo = ffi.new("bool[1]",true)
    while (not done) do
        --SDL_Event 
        local event = ffi.new"SDL_Event"
        while (sdl.pollEvent(event) ~=0) do
            ig.lib.ImGui_ImplSDL2_ProcessEvent(event);
            if (event.type == sdl.QUIT) then
                done = true;
            end
            if (event.type == sdl.WINDOWEVENT and event.window.event == sdl.WINDOWEVENT_CLOSE and event.window.windowID == sdl.getWindowID(window)) then
                done = true;
            end
        end
        --standard rendering
        sdl.gL_MakeCurrent(window, gl_context);
        gl.glViewport(0, 0, igio.DisplaySize.x, igio.DisplaySize.y);
        gl.glClear(glc.GL_COLOR_BUFFER_BIT)

        ig_Impl:NewFrame()
        
        if ig.Button"Hello" then
            print"Hello World!!"
        end
        
        ig.Image(ffi.cast("void*", logo_tex[0]), ig.ImVec2(image_width, image_height))
        
        ig.ShowDemoWindow(showdemo)
        ig.ShowMetricsWindow()
        
        ig_Impl:Render()
        sdl.gL_SwapWindow(window);
    end
    
    -- Cleanup
    ig_Impl:destroy()

    sdl.gL_DeleteContext(gl_context);
    sdl.destroyWindow(window);
    sdl.quit();

