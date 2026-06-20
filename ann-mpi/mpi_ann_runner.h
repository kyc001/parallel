// Header-only MPI ANN modules used by the course submission entry.
//
// The server still builds only main.cc:
//   mpic++ main.cc -o main -O2 -std=c++11 -I. -fopenmp -lpthread

#pragma once

#include "mpi/common.h"
#include "mpi/params.h"
#include "mpi/data.h"
#include "mpi/candidates.h"
#include "mpi/search.h"
#include "mpi/output.h"
#include "mpi/comm.h"
