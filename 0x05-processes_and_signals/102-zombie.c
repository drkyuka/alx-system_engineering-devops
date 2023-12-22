#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

/**
 * infinite_while - function sleeps for one second and repeats indefinitely
 *
 * Return: int
 */
int infinite_while(void)
{
	while (1)
	{
		sleep(1);
	}
	return (0);
}

/**
 * main - function runs the main function
 *
 * Return: int
 */
int main(void)
{
	int i;
	pid_t zombie;

	for (i = 0; i < 5; i++)
	{
		zombie = fork();

		if (!zombie)
			return (0);

		printf("Zombie process created, PID: %d\n", zombie);
	}
	infinite_while();
	return (0);
}
