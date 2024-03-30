#define LX_CONVERT_JBROOT_PATH_CSTRING(path) ({ \
    char resolved_path[PATH_MAX]; \
    lx_convert_jbroot_path_cstring(path, resolved_path); \
})

char* lx_convert_jbroot_path_cstring(char* original_path, char* resolved_path);