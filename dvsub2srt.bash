# !/bin/bash
# OUTPUT-COLORING
red=$( tput setaf 1 )
green=$( tput setaf 2 )
NC=$( tput sgr0 )      # or perhaps: tput sgr0
#NC=$( tput setaf 0 )      # or perhaps: tput sgr0

# Dépendances : ffmpeg,  mkvtoolnix, vobsub2srt
# Signale quel programme l'on exécute
# puis la composition du répertoire où le script s'exécute
echo -e "programme pour extraire des canaux de sous-titres d'une vidéo\n
Composition du répertoire courant :\n
$(ls)"

# Invite de commande pour entrer le fichier vidéo à traiter
echo -n "Entrer le fichier vidéo choisi :";
read film_a_traiter;

# Message pour informer l'utilisateur de son choix
echo -e "Le fichier vidéo choisi est : \n $film_a_traiter"

# Exemple film_a_traiter="RetourVersLeFutur2.mp4"
# film_a_traiter="RetourVersLeFutur2.mp4"

# soustitres_array= ("4|fra" "5|fra")
soustitres_array=($(ffprobe $film_a_traiter -v quiet -show_entries stream=index:stream_tags=language -select_streams s -of compact=p=0:nk=1))

# metadata_sub="-map 0:4 -metadata:s:s:1 language=fra -map 0:5 -metadata:s:s:2 language=fra"
metadata_sub=$(for (( c=0; c<${#soustitres_array[@]}; c++));  do  echo -map 0:$(echo ${soustitres_array[$c]} | cut -d "|" -f1) -metadata:s:s:$(($c + 1)) language=$(echo ${soustitres_array[$c]} | cut -d "|" -f2) ; done)

# command1="ffmpeg -i RetourVersLeFutur2.mp4 -map 0:4 -metadata:s:s:1 language=fra -map 0:5 -metadata:s:s:2 language=fra -c:s dvdsub sous_titres_RetourVersLeFutur2.mp4.mk"
command1=$(echo "ffmpeg -i $film_a_traiter $metadata_sub -c:s dvdsub sous_titres_$film_a_traiter.mkv")

# Execution commande n°1 $command1
$command1

# vobsub_piste="0:0_ 1:1_"
vobsub_piste=$(for (( c=0; c<${#soustitres_array[@]}; c++)); do echo $c:$c"_"; done)

#command2="mkvextract tracks sous_titres_RetourVersLeFutur2.mp4.mkv -c ISO8859-1 0:0_ 1:1_"
command2=$(echo "mkvextract tracks sous_titres_$film_a_traiter.mkv -c ISO8859-1 $vobsub_piste")

# Execution commande n°2 $command2
$command2

# Exécution Roc des fichiers de sous-titres
#vobsub2srt 0_; vobsub2srt 1_;"
for (( c=0; c<${#soustitres_array[@]}; c++));
do
 vobsub2srt $c"_";
done
exit 0;
