clc
clear
close all

model = loadModel('fire_test_model.mat');

cells_pack = ["cell_.*","connector_.*","casing_inner.*", "holder.*", "bus_bar.*"];

cells = ["cell_.*","connector_.*"];

model.displayComponents(cells_pack);
model.displayComponents(cells);

% w = wizard.WizardGUI();

plot([0,70,71,130,131,200],[2500,2500,2000,2000,25,25], 'LineWidth',2);
title('Temperature profile at the boundary')
xlabel('Time [s]')
ylabel('Temperature [deg C]')

current_profile = table([0; 12800], [60; 60]);
current_profile.Properties.VariableNames = {'t','current'};

model.setCurrentProfile('ele_circ', current_profile);

model.setIC(".*", 'T', 25);

model.setIC("cell_.*", 'T', 25, 'SOC', 0.6);

%model.flag_is_parallel = true;

tic;
model_struct = model.prepare();
model_prepare_time = toc;
fprintf("Model preparation took %4.1f seconds.", model_prepare_time)

% save('model_struct.mat','model_struct');
% model.saveModel('model_preped.mat');

tic;
model.run(1, 130, 'maxSubIter', 20, 'electroSubsteps', 20, 'solver', 'Direct', ...
    'signals_data', model_struct);
model_run_time = toc;
fprintf("Simulation run took %4.1f seconds.", model_run_time)

model.plotMaxTempOverTime("cell_cores")

model.plotMeanTempOverTime("cell_cores")
model.plotMaxTempOverTime("casings_together")
model.plotMeanTempOverTime("casings_together")
model.plotSolution(cells_pack)
model.plotSolution(cells)
model.plotSOCOverTime()
model.plotCurrentOverTime()
model.plotCircuitVoltage()

% model.exportSolutionToCGNS(".*", 'fire_test.cgns', 200);

%% Remove the battery pack from the heating source and adjust the time step from 1 s to 100 s 
tic;

model.run(100, 120, 'maxSubIter', 20, 'electroSubsteps', 20, 'solver', 'Direct', ...
    'signals_data', model_struct, 'startStep', 131);

model_run_time2 = toc;
fprintf("Simulation run took %4.1f seconds.", model_run_time2)

model.plotMaxTempOverTime("cell_cores")
model.plotMeanTempOverTime("cell_cores")

model.plotMaxTempOverTime("casings_together")
model.plotMeanTempOverTime("casings_together")

model.plotSolution(cells_pack)
model.plotSolution(cells)