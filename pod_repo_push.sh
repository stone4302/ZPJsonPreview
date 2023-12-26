#!/bin/bash


echo "enter dir: `pwd`"

pod repo push 58corp-zpspecs ZPJsonPreview.podspec --allow-warnings --sources="git@igit.58corp.com:HRG-Client/iOS/ZPSpecs.git" --use-libraries
