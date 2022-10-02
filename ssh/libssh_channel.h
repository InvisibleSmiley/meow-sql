#ifndef SSH_LIBSSH_CHANNEL_H
#define SSH_LIBSSH_CHANNEL_H

#include <libssh/libssh.h>

namespace meow::ssh {

class LibSSHChannel
{
public:
    explicit LibSSHChannel(const ssh_session* session);

    ~LibSSHChannel();

    void setBlocking(int blocking);

    int openForward(const char* remotehost, int remoteport,
                    const char* sourcehost, int localport);

    int write(const void* data, uint32_t len);

    int readNonBlocking(void* dest, uint32_t count, int is_stderr);

    int read(void* dest, uint32_t count, int is_stderr);

    int poll(int is_stderr);

    int pollForMs(int is_stderr, uint32_t ms);


private:
    ssh_channel _channel;
};

} // namespace meow::ssh

#endif
