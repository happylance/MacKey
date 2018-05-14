//
//  Reducer.swift
//  MacKeyUnit
//
//  Created by Liu Liang on 5/9/18.
//  Copyright © 2018 Liu Liang. All rights reserved.
//

typealias Reducer<State, InputAction, OutputAction> = (State, InputAction) -> (State, OutputAction?)

typealias SimpleReducer<State, Action> = (State, Action) -> State
