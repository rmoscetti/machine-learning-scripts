import os
from PIL import Image

def remove_alpha(input_path, output_path):
    img = Image.open(input_path)
    if img.mode == 'RGBA':
        img = img.convert("RGB")
        print(f"Alpha rimosso - {output_path}\n")
        img.save(output_path)
    else:
        print(f"Alpha non presente - {output_path}\n")
   
def process_images(input_folder, output_folder):
    if not os.path.exists(input_folder):
        print(f"Errore: la cartella di origine '{input_folder}' non esiste!")
        return
    
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
        print(f"Cartella di destinazione creata: {output_folder}")
    
    for filename in os.listdir(input_folder):
        input_path = os.path.join(input_folder, filename)
        
        if filename.lower().endswith('.tiff') or filename.lower().endswith('.tif'):
            output_path = os.path.join(output_folder, filename)
            remove_alpha(input_path, output_path)
        else:
            print(f"Il seguente file non è TIFF e sarà ignorato: {filename}")

if __name__ == "__main__":
    input_folder = "./alpha"
    output_folder = "./non_alpha"
    process_images(input_folder, output_folder)
