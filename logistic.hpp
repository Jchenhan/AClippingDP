#ifndef LOGISTIC_H
#define LOGISTIC_H
#include "blackbox.hpp"
#include "regularizer.hpp"

class logistic: public blackbox {
public:
    logistic(int params_no, double* params, int regular = regularizer::ELASTIC_NET);
    logistic(double param, int _regularizer = regularizer::L2);
    int classify(double* sample) const override;
    double zero_component_oracle_dense(double* X, double* Y, int N, int start_point, double* weights = NULL) const override;
    double zero_component_oracle_sparse(double* X, double* Y, int* Jc, int* Ir, int N, double* weights = NULL) const override;
    double first_component_oracle_core_dense(double* X, double* Y, int N, int given_index, double* weights = NULL) const override;
    double first_component_oracle_core_sparse(double* X, double* Y, int* Jc, int* Ir, int N, int given_index, double* weights = NULL) const override;
};

#endif
