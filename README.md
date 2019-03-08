# Foot Renderer
A data synthesizer for creating datasets of feet from a first-person perspective.

## Why?

Need dataset for training models for apps like a soccer game.

## Intro
We threw this project together as part of the talk [Creating an Augmented Reality Football Game in a weekend](https://www.youtube.com/watch?v=FiJc1Fh4ros).  This project is currently setup to generat images and [segmentation masks](https://en.wikipedia.org/wiki/Image_segmentation) to be used in training a foot detector.

We have included enough few feet, floors, and leg textures to get started training a prototype foot detector.  This project should be taken as a jumping off point for data synthesis rather than a production-grade solution.

For production applications, you will probably need a higher prediction accuracy. or more robust modeling needs, you 

This project should be taken rather as a jumping off point to create a model for detecting the position of a foot to interact with objects in a scene.



To improve the dataset (e.g. for production app), add more variations of feet, floors.




Open the xcode project, build, and run to start generating feet.

### Directory structure
- **FootRenderer/** (source for renderer)
- **FootRenderer.xcodeproj** (Xcode project)
- **input/** (images used in synthesis: floors, feet)
- **output/** (synthesized dataset)


## TODO

cleanup
