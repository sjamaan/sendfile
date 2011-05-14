(foreign-declare "#include <sys/sendfile.h>\n#include <fcntl.h>\n#include<errno.h>")
(cond-expand
  (posix-fadvise
   (foreign-declare "#define READ_AHEAD (4 * 1024 * 1024)")
   (define %sendfile-implementation
     (foreign-lambda* double ((integer src) (integer dst) (double offset) (unsigned-integer to_send))
       "size_t res = 0;"
       "off_t curoffset = (off_t)offset;"
       "if((posix_fadvise(src,0,0,POSIX_FADV_SEQUENTIAL) < 0) && errno != ENOSYS){ C_return(-1); }"
       "if(sendfile(dst,src,&curoffset,to_send) < 0){"
       "   if(errno == EAGAIN || errno == EINTR){ C_return(-2); }"
       "   C_return(-1);"
       "}"
       " if(((off_t)offset & ~(READ_AHEAD - 1)) != (((off_t)offset + res) & ~(READ_AHEAD - 1))){"
       "  if(posix_fadvise(src,((off_t)offset + res) & ~(READ_AHEAD - 1),READ_AHEAD,POSIX_FADV_NOREUSE) < 0){"
       "    C_return(-1);"
       "  }"
       "}"
       "C_return((double)curoffset);")))
  (else
   (define %sendfile-implementation
     (foreign-lambda*  double ((integer src) (integer dst) (double offset) (unsigned-integer to_send))
       "size_t res = 0;"
       "off_t curoffset = (off_t)offset;"
       "if(sendfile(dst,src,&curoffset,to_send) < 0){"
       "   if(errno == EAGAIN || errno == EINTR){ C_return(-2); }"
       "   C_return(-1);"
       "}"
       "C_return((double)curoffset);"))))

