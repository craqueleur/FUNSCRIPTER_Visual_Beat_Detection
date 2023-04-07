clear all

% Spécifiez le nom du fichier vidéo en tant qu'argument

%filename = 'Fap Hero_Cummodus_V1.1_Upscaled_(2160).mp4'; % Give the name of the video !
filename = 'cit.mov'; % Give the name of the video !
outputfilename2='FINALWORKING1111100011513.funscript'
% Spécifiez le nom des fichiers de sortie

%%%you can ignore the next names

filenames = '1111111000115123.funscript';

newFilename = '211111000115123.funscript';

outputfilename='311111000115123.funscript';

% Ouvrez le fichier vidéo à l'aide de la fonction VideoReader

video = VideoReader(filename);

% Spécifiez les coordonnées x et y du pixel à vérifier

x = 700; %centre

y = 1059; %These coordinates are at the bottom mid in the beatbar

% Spécifiez la couleur à détecter

colorToDetect = [205 205 205]; % Remplacez R, G et B par les valeurs de la couleur à détecter

%40 40 40 detects black

% Spécifiez la tolérance de couleur

colorTolerance = 60; % Ajustez cette valeur selon votre besoin

% Initialisation de la variable d'état du pixel

pixelState = 0;

% Initialisation de la variable du temps écoulé

elapsedTime = 0;

% Initialisation de la liste des amplitudes

amplitudesList = {};

% Boucle à travers toutes les frames de la vidéo

while hasFrame(video)

% Lit la frame suivante

frame = readFrame(video);

% Récupère la différence de couleur entre le pixel à vérifier et la couleur à détecter

colorDifference = getColorDifference(frame, x, y, colorToDetect);

% Vérifie si la couleur du pixel correspond à la couleur à détecter

if all(colorDifference <= colorTolerance)

% Si la couleur correspond et que le pixel n'était pas déjà à l'état 0

if pixelState ~= 0

% Ajoute l'amplitude 0% dans la liste des amplitudes

amplitudesList{end+1} = struct('pos', 0, 'at', floor(elapsedTime));

% Met à jour l'état du pixel à 0

pixelState = 0;

end

else

% Si la couleur ne correspond pas et que le pixel n'était pas déjà à l'état 100%

if pixelState ~= 100

% Ajoute l'amplitude 100% dans la liste des amplitudes

amplitudesList{end+1} = struct('pos', 100, 'at', floor(elapsedTime));

% Met à jour l'état du pixel à 100%

pixelState = 100;

end

end

% Met à jour le temps écoulé

elapsedTime = elapsedTime + (1 / video.FrameRate) * 1000; % Convertit le temps en millisecondes

% Si la liste des amplitudes dépasse les 10 éléments, écrit les amplitudes dans le fichier funscript et vide la liste

if numel(amplitudesList) >= 200

% Écrit les amplitudes dans le fichier funscript

funscript = jsonencode(amplitudesList);

fid = fopen(filenames, 'a');

fprintf(fid, funscript);

fclose(fid);

amplitudesList = {};

end

end

% Si la liste des amplitudes n'est pas vide, écrit les amplitudes restantes dans le fichier funscript

if ~isempty(amplitudesList)

% Écrit les amplitudes dans le fichier funscript

funscript = jsonencode(amplitudesList);

fid = fopen(filenames, 'a');

fprintf(fid, funscript);

fclose(fid);

end

% Définir le nom du fichier d'entrée et de sortie

% Ouvrir le fichier d'entrée

fileID = fopen(filenames,'r');

% Lire le contenu du fichier

fileContent = fscanf(fileID,'%c');

% Fermer le fichier d'entrée

fclose(fileID);

%%%%%%%%Partie supression des exposants

%%%%%%Partie ajout des saut de ligne pour permettre la supression

%%%%%%d'exposants

% Lire le contenu du fichier texte

fid = fopen(filenames, 'r');

text = fread(fid, '*char').';

fclose(fid);

% Remplacer toutes les occurrences de '][' par ']\n['

text_new = strrep(text, '][', sprintf(']\n['));

% Écrire la chaîne modifiée dans un nouveau fichier texte

fid = fopen(filenames, 'w');

fwrite(fid, text_new);

fclose(fid);

fid = fopen(filenames,'r');

% Parcourir chaque ligne du fichier

while true

% Lire une ligne du fichier

line = fgetl(fid);

% Vérifier si on est arrivé à la fin du fichier

if line == -1

break;

end

% Vérifier si la ligne contient une liste JSON

if contains(line, '[') && contains(line, ']')

% Convertir la ligne en une liste de dictionnaires

inputList = jsondecode(line);

% Parcourir chaque élément de la liste et convertir la valeur de "at"

for i = 1:length(inputList)

inputList(i).at = sprintf('%.0f', inputList(i).at);

end

% Écrire la liste modifiée dans le fichier de sortie

fileID = fopen(outputfilename,'a');

fprintf(fileID, '%s\n', jsonencode(inputList));

fclose(fileID);

% Effacer la liste de la mémoire Matlab

clear inputList;

end

end

%%%%%%%%%%% Partie fusionne liste enlevant les crochets

% spécifiez le nom du fichier d'entrée et de sortie

filename_in = outputfilename;

filename_out = outputfilename2;

% lisez le contenu du fichier d'entrée dans une chaîne de caractères

text = fileread(filename_in);

% remplacez tous les occurrences de ']\s*\[' par ','

text = regexprep(text, ']\s*\[', ',');

% écrivez la chaîne résultante dans le fichier de sortie

fid = fopen(filename_out, 'w');

fwrite(fid, text, 'char');

fclose(fid);

%%%%%%%%%%%%%%% Partie Ajouter les informations au début du fichier

filename = filename_out;

fid = fopen(filename_out,'r');

content = fread(fid, inf, 'uint8=>char')';

fclose(fid);

newContent = sprintf('{\n "version": "1.0",\n "inverted": false,\n "range": 100,\n "info": "Automatic generation script from Pixel colour",\n "actions":\n%s', content);

fid = fopen(filename,'w');

fwrite(fid, newContent, 'char');

fclose(fid);

%%%%%%Ajout de l'acolade de fin

fid = fopen(filename_out, 'a');

% texte à ajouter

texte = sprintf('}');

% écrire le texte dans le fichier

fprintf(fid, '%s', texte);

% fermer le fichier

fclose(fid);

% delete(filenames)

% delete(newFilename)

% delete(outputfilename)

function colorDifference = getColorDifference(img, x, y, colorToDetect)

pixelColor = double(img(y, x, :));

colorDifference = abs(pixelColor - double(colorToDetect));

end