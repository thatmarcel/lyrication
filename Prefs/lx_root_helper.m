#import <unistd.h>
#import <dlfcn.h>
#import <sys/syslimits.h>
#import <string.h>

char* lx_convert_jbroot_path_cstring(char* original_path, char* resolved_path) {
    void* handle = dlopen("@rpath/libroot.dylib", RTLD_NOW | RTLD_GLOBAL | RTLD_NODELETE);
    
    char *(*lx_dyn_jbrootpath)(const char *path, char *resolvedPath) = dlsym(handle, "libroot_jbrootpath");
    
    if (lx_dyn_jbrootpath) {
        lx_dyn_jbrootpath(original_path, resolved_path);
    } else {
        #ifdef THEOS_PACKAGE_INSTALL_PREFIX
        strcpy(resolved_path, "/var/jb");
        strcat(resolved_path, original_path);
        #else
        if (access("/var/LIY", F_OK) == 0) {
            strcpy(resolved_path, "/var/jb");
            strcat(resolved_path, original_path);
        } else {
            strcpy(resolved_path, original_path);
        }
        #endif
    }
    
    return resolved_path;
}