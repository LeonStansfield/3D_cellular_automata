import os

def duplicate_and_rename_files(folder_path, new_folder_name):
    # Create a new folder with the desired name
    new_folder_path = os.path.join(os.path.dirname(folder_path), new_folder_name)
    os.makedirs(new_folder_path, exist_ok=True)

    # Iterate through files in the original folder
    for root, dirs, files in os.walk(folder_path):
        for file_name in files:
            # Get the file extension
            file_extension = os.path.splitext(file_name)[1]

            # Generate the new file name
            new_file_name = file_name.replace('0', '270')

            # Create the paths for the original and new files
            original_file_path = os.path.join(root, file_name)
            new_file_path = os.path.join(new_folder_path, new_file_name)

            # Duplicate the file with the new name
            with open(original_file_path, 'rb') as original_file, open(new_file_path, 'wb') as new_file:
                new_file.write(original_file.read())

            print(f"Duplicated and renamed: {file_name} --> {new_file_name}")

    print("Duplication and renaming process completed.")

# Example usage
folder_path = '0'
new_folder_name = '270'
duplicate_and_rename_files(folder_path, new_folder_name)
