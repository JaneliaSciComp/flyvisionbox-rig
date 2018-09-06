load('Protocol5.09_34.exp','-mat')

for i = 1:2,
    for j = 1:length(experiment.actionlist(i).action)
    if experiment.actionlist(i).action(j).command(1) == 7,
        experiment.actionlist(i).action(j).command(2) = experiment.actionlist(i).action(j).command(2) -1;
    end
    end
end