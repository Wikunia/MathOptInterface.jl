@testset "Basic Constraint Tests" begin
    mock   = MOIU.MockOptimizer(Model{Float64}())
    config = MOIT.TestConfig()
    MOIT.basic_constraint_tests(mock, config)
end

@testset "Unit Tests" begin
    mock = MOIU.MockOptimizer(Model{Float64}())
    config = MOIT.TestConfig()
    MOIT.unittest(mock, config, [
        "solve_blank_obj",
        "solve_constant_obj",
        "solve_singlevariable_obj",
        "solve_with_lowerbound",
        "solve_with_upperbound",
        "solve_affine_lessthan",
        "solve_affine_greaterthan",
        "solve_affine_equalto",
        "solve_affine_interval",
        "solve_qp_edge_cases",
        "solve_qcp_edge_cases",
        "solve_affine_deletion_edge_cases",
        "solve_duplicate_terms_obj",
        "solve_integer_edge_cases",
        "solve_objbound_edge_cases"
        ])

    @testset "solve_blank_obj" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1]),
                MOI.FEASIBLE_POINT
            )
        )
        MOIT.solve_blank_obj(mock, config)
        # The objective is blank so any primal value ≥ 1 is correct
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [2]),
                MOI.FEASIBLE_POINT
            )
        )
        MOIT.solve_blank_obj(mock, config)
    end
    @testset "solve_constant_obj" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1]),
                MOI.FEASIBLE_POINT
            )
        )
        MOIT.solve_constant_obj(mock, config)
    end
    @testset "solve_singlevariable_obj" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1]),
                MOI.FEASIBLE_POINT
            )
        )
        MOIT.solve_singlevariable_obj(mock, config)
    end
    @testset "solve_with_lowerbound" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1]),
                MOI.FEASIBLE_POINT,
                    (MOI.SingleVariable, MOI.GreaterThan{Float64}) => [2.0],
                    (MOI.SingleVariable, MOI.LessThan{Float64})    => [0.0]
            )
        )
        # x has two variable constraints
        mock.eval_variable_constraint_dual = false
        MOIT.solve_with_lowerbound(mock, config)
        mock.eval_variable_constraint_dual = true
    end
    @testset "solve_with_upperbound" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1]),
                MOI.FEASIBLE_POINT,
                    (MOI.SingleVariable, MOI.LessThan{Float64})    => [-2.0],
                    (MOI.SingleVariable, MOI.GreaterThan{Float64}) => [0.0]
            )
        )
        # x has two variable constraints
        mock.eval_variable_constraint_dual = false
        MOIT.solve_with_upperbound(mock, config)
        mock.eval_variable_constraint_dual = true
    end
    @testset "solve_affine_lessthan" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [0.5]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.LessThan{Float64}) => [-0.5]
            )
        )
        MOIT.solve_affine_lessthan(mock, config)
    end
    @testset "solve_affine_greaterthan" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [0.5]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.GreaterThan{Float64}) => [0.5]
            )
        )
        MOIT.solve_affine_greaterthan(mock, config)
    end
    @testset "solve_affine_equalto" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [0.5]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.EqualTo{Float64}) => [0.5]
            )
        )
        MOIT.solve_affine_equalto(mock, config)
    end
    @testset "solve_affine_interval" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [2.0]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.Interval{Float64}) => [-1.5]
            )
        )
        MOIT.solve_affine_interval(mock, config)
    end

    @testset "solve_qcp_edge_cases" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [0.5, 0.5])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [0.5, (√13 - 1)/4])
            )
        )
        MOIT.solve_qcp_edge_cases(mock, config)
    end

    @testset "solve_qp_edge_cases" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1.0, 2.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1.0, 2.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1.0, 2.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1.0, 2.0])
            )
        )
        MOIT.solve_qp_edge_cases(mock, config)
    end
    @testset "solve_duplicate_terms_obj" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL,
                (MOI.FEASIBLE_POINT, [1]),
                MOI.FEASIBLE_POINT
            )
        )
        MOIT.solve_duplicate_terms_obj(mock, config)
    end
    @testset "solve_affine_deletion_edge_cases" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [2.0])
            )
        )
        MOIT.solve_affine_deletion_edge_cases(mock, config)
    end
    @testset "solve_integer_edge_cases" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [2.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.0])
            )
        )
        MOIT.solve_integer_edge_cases(mock, config)
    end
    @testset "solve_objbound_edge_cases" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> begin
                MOI.set(mock, MOI.ObjectiveBound(), 3.0)
                MOIU.mock_optimize!(mock, MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [2.0]))
            end,
            (mock::MOIU.MockOptimizer) -> begin
                MOI.set(mock, MOI.ObjectiveBound(), 3.0)
                MOIU.mock_optimize!(mock, MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0]))
            end,
            (mock::MOIU.MockOptimizer) -> begin
                MOI.set(mock, MOI.ObjectiveBound(), 2.0)
                MOIU.mock_optimize!(mock, MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.5]))
            end,
            (mock::MOIU.MockOptimizer) -> begin
                MOI.set(mock, MOI.ObjectiveBound(), 4.0)
                MOIU.mock_optimize!(mock, MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.5]))
            end
        )
        MOIT.solve_objbound_edge_cases(mock, config)
    end

end

@testset "modifications" begin
    mock   = MOIU.MockOptimizer(Model{Float64}())
    config = MOIT.TestConfig()
    @testset "solve_set_singlevariable_lessthan" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0]),
                MOI.FEASIBLE_POINT
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [2.0]),
                MOI.FEASIBLE_POINT
            )
        )
        MOIT.solve_set_singlevariable_lessthan(mock, config)
    end
    @testset "solve_transform_singlevariable_lessthan" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0]),
                MOI.FEASIBLE_POINT
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [2.0]),
                MOI.FEASIBLE_POINT
            )
        )
        MOIT.solve_transform_singlevariable_lessthan(mock, config)
    end
    @testset "solve_set_scalaraffine_lessthan" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.LessThan{Float64}) => [-1.0]
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [2.0]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.LessThan{Float64}) => [-1.0]
            )
        )
        MOIT.solve_set_scalaraffine_lessthan(mock, config)
    end
    @testset "solve_coef_scalaraffine_lessthan" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.LessThan{Float64}) => [-1.0]
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.5]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.LessThan{Float64}) => [-0.5]
            )
        )
        MOIT.solve_coef_scalaraffine_lessthan(mock, config)
    end
    @testset "solve_func_scalaraffine_lessthan" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.LessThan{Float64}) => [-1.0]
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.5]),
                MOI.FEASIBLE_POINT,
                    (MOI.ScalarAffineFunction{Float64}, MOI.LessThan{Float64}) => [-0.5]
            )
        )
        MOIT.solve_func_scalaraffine_lessthan(mock, config)
    end
    @testset "solve_const_vectoraffine_nonpos" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.0, 0.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0, 0.75])
            )
        )
        MOIT.solve_const_vectoraffine_nonpos(mock, config)
    end
    @testset "solve_multirow_vectoraffine_nonpos" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.5])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [0.25])
            )
        )
        MOIT.solve_multirow_vectoraffine_nonpos(mock, config)
    end
    @testset "solve_const_scalar_objective" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            )
        )
        MOIT.solve_const_scalar_objective(mock, config)
    end
    @testset "solve_coef_scalar_objective" begin
        MOIU.set_mock_optimize!(mock,
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            ),
            (mock::MOIU.MockOptimizer) -> MOIU.mock_optimize!(mock,
                MOI.OPTIMAL, (MOI.FEASIBLE_POINT, [1.0])
            )
        )
        MOIT.solve_coef_scalar_objective(mock, config)
    end
end