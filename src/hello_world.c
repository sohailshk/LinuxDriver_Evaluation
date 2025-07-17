/*
 * hello_world.c - A simple character device driver
 *
 * This driver creates a character device that supports basic read/write
 * operations with a 1KB internal buffer.
 *
 * Author: AI Generated Driver
 * License: GPL
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <linux/slab.h>
#include <linux/string.h>

#define DEVICE_NAME "hello_world"
#define CLASS_NAME "hello"
#define BUFFER_SIZE 1024

MODULE_LICENSE("GPL");
MODULE_AUTHOR("AI Generated Driver");
MODULE_DESCRIPTION("A simple character device driver");
MODULE_VERSION("1.0");

static int major_number;
static char *message;
static short size_of_message;
static int number_opens;
static struct class *hello_class;
static struct device *hello_device;

/* Function prototypes */
static int dev_open(struct inode *inodep, struct file *filep);
static int dev_release(struct inode *inodep, struct file *filep);
static ssize_t dev_read(struct file *filep, char *buffer, size_t len,
			loff_t *offset);
static ssize_t dev_write(struct file *filep, const char *buffer, size_t len,
			 loff_t *offset);

static const struct file_operations fops = {
	.open = dev_open,
	.read = dev_read,
	.write = dev_write,
	.release = dev_release,
};

static int __init hello_init(void)
{
	int ret;

	pr_info("HelloWorld: Initializing the HelloWorld LKM\n");

	/* Allocate buffer */
	message = kmalloc(BUFFER_SIZE, GFP_KERNEL);
	if (!message) {
		pr_err("HelloWorld: Failed to allocate memory\n");
		return -ENOMEM;
	}

	/* Try to dynamically allocate a major number */
	major_number = register_chrdev(0, DEVICE_NAME, &fops);
	if (major_number < 0) {
		pr_err("HelloWorld: Failed to register major number\n");
		kfree(message);
		return major_number;
	}
	pr_info("HelloWorld: Registered correctly with major number %d\n",
		major_number);

	/* Register the device class */
	hello_class = class_create(THIS_MODULE, CLASS_NAME);
	if (IS_ERR(hello_class)) {
		ret = PTR_ERR(hello_class);
		pr_err("HelloWorld: Failed to register device class\n");
		unregister_chrdev(major_number, DEVICE_NAME);
		kfree(message);
		return ret;
	}
	pr_info("HelloWorld: Device class registered correctly\n");

	/* Register the device driver */
	hello_device = device_create(hello_class, NULL, MKDEV(major_number, 0),
				     NULL, DEVICE_NAME);
	if (IS_ERR(hello_device)) {
		ret = PTR_ERR(hello_device);
		pr_err("HelloWorld: Failed to create the device\n");
		class_destroy(hello_class);
		unregister_chrdev(major_number, DEVICE_NAME);
		kfree(message);
		return ret;
	}
	pr_info("HelloWorld: Device class created correctly\n");

	strcpy(message, "Hello from kernel space!");
	size_of_message = strlen(message);
	number_opens = 0;

	return 0;
}

static void __exit hello_exit(void)
{
	device_destroy(hello_class, MKDEV(major_number, 0));
	class_unregister(hello_class);
	class_destroy(hello_class);
	unregister_chrdev(major_number, DEVICE_NAME);
	kfree(message);
	pr_info("HelloWorld: Goodbye from the LKM!\n");
}

static int dev_open(struct inode *inodep, struct file *filep)
{
	number_opens++;
	pr_info("HelloWorld: Device has been opened %d time(s)\n",
		number_opens);
	return 0;
}

static ssize_t dev_read(struct file *filep, char *buffer, size_t len,
			loff_t *offset)
{
	int error_count = 0;

	if (*offset >= size_of_message)
		return 0; /* EOF */

	if (*offset + len > size_of_message)
		len = size_of_message - *offset;

	error_count = copy_to_user(buffer, message + *offset, len);

	if (error_count == 0) {
		*offset += len;
		pr_info("HelloWorld: Sent %zu characters to the user\n", len);
		return len;
	}

	pr_info("HelloWorld: Failed to send %d characters to the user\n",
		error_count);
	return -EFAULT;
}

static ssize_t dev_write(struct file *filep, const char *buffer, size_t len,
			 loff_t *offset)
{
	int error_count = 0;

	if (len > BUFFER_SIZE - 1)
		len = BUFFER_SIZE - 1;

	error_count = copy_from_user(message, buffer, len);

	if (error_count == 0) {
		message[len] = '\0';
		size_of_message = len;
		pr_info("HelloWorld: Received %zu characters from the user\n",
			len);
		return len;
	}

	pr_info("HelloWorld: Failed to receive %d characters from the user\n",
		error_count);
	return -EFAULT;
}

static int dev_release(struct inode *inodep, struct file *filep)
{
	pr_info("HelloWorld: Device successfully closed\n");
	return 0;
}

module_init(hello_init);
module_exit(hello_exit);
