#!/bin/bash

project_name="com.github.kmalkenneth.monilet"

# Install icons
icon_sizes=('32' '48' '64' '128')

for i in "${icon_sizes[@]}"; do

    echo "Installing '$i'x'$i' icon"
    install -D metadata/data/icons/"$i"/"$project_name".svg linux/packaging/usr/share/icons/hicolor/"$i"x"$i"/apps/"$project_name".svg
    install -D metadata/data/icons/"$i"/"$project_name".svg linux/packaging/usr/share/icons/hicolor/"$i"x"$i"@2/apps/"$project_name".svg
done

echo "Installing binary files"
cp  build/linux/x64/release/bundle/monilet build/linux/x64/release/bundle/"$project_name"
cp -fr build/linux/x64/release/bundle linux/packaging/usr/bin

echo "Building metadata"
cd metadata || exit
meson build --prefix=/usr
cd build || exit
ninja install
cd ../.. || exit

echo "Create AppDir"
mkdir AppDir

echo "Copy files to AppDir"
cp -r linux/packaging/usr AppDir

echo "linking binary"
ln -sr AppDir/usr/bin/"$project_name" AppDir/"$project_name"

echo "Create tarball"
my_event=""

if [ "${github.event_name}" == 'release' ] && [ "${github.event.release.tag_name}" ]; then
    my_event=github.event_name
else
    my_event="continuous"
fi

tar czf "${project_name}-${my_event}-x86_64.tar.gz" -C AppDir/ 
