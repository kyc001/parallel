#import "@preview/touying:0.6.1": *
#import themes.metropolis: *

#show: metropolis-theme.with(aspect-ratio: "16-9")

#title-slide[
  = Test Slide
  Author Name
  #datetime.today().display()
]

#slide[
  = Hello
  World
]
