#include <unistd.h>
#include <sys/mman.h>
#include <stdio.h>

void
main(int argc, char **argv)
{
	/*create a private mapping of memory
	 * independent of the program's heap*/
	void *ptr = mmap(NULL, sizeof(int), PROT_READ | PROT_WRITE,
						MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	*(int *)ptr = 5;
	/*print 5*/
	printf("%d\n", *(int *)ptr);
	munmap(ptr, sizeof(int));/*free that map*/
	return;
}
