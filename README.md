# Andreas_file_tools

In my pursuit to retrieve my music from the cloud, I find myself once again at a juncture where I need to work with folders and file names. 
In doing so, I've rediscovered the issue of having similar folder and file names. 
If you have a large music collection, you sometimes encounter similar folders and names, which can lead to a huge mess, especially if you try to use Rockbox and other devices that utilize flash cards and the FAT32 systems.
My goal was to reduce this mess. 

So, here is an example of how i tryed to solve this problem:

Let's say you encounter the following folder structure:

![file_structure](https://github.com/andreas-ullrich/Andreas_file_tools/assets/68023686/686088c3-9e67-43f9-a17d-641ee6c0483b)


You can already see some folders with similar sounding names. 
The problem becomes more significant the more folders you have. 
Since I'm lazy and wanted to try GPT-4, I decided to outsource the task of organizing the folders to the machine.

So, I wrote a Bash script that would send the folder structure to ChatGPT, and ChatGPT would suggest the correct folder names. 
Then, the script would move the files into the right folders.

After the first run it will look like this:


![first_run](https://github.com/andreas-ullrich/Andreas_file_tools/assets/68023686/64976e42-5402-4591-aab6-ab614b8a4e7a)
![first_run_srtructure](https://github.com/andreas-ullrich/Andreas_file_tools/assets/68023686/990d001d-9929-4ad5-b0db-806e9911f164)

After the second run it finaly got them all:

![second_run_srtructure](https://github.com/andreas-ullrich/Andreas_file_tools/assets/68023686/51e1d52e-3e11-4ee7-ba7d-fcda9462a734)
![second_run](https://github.com/andreas-ullrich/Andreas_file_tools/assets/68023686/5598c7fc-8d7c-4644-9e7c-09beebd30726)

So, as you can see, it identified almost all the duplicates and consolidated their folders. 
It is not foolproof, so be careful with your data. Make a dry run first. Anyway, I hope it will help you out.

Requieres: jq and ChatGPT API access.

### WARNING: USE ON TEST DATA ONLY.

# how to use it:
1. copy the bash script into a folder with the folders you want to organize
2. add your ChatGPT API Key into script
3. run the script
