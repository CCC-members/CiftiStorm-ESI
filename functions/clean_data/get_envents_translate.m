function events_translate = get_envents_translate()

Op_eyes = {'open_eyes','ojos_abiertos','eyes_opened','Op_eyes'};
Cl_eyes = {'closed_eyes','ojos_cerrados','eyes_closed','Cl_eyes'};
Hyper_1 = {'hyperventilation_1','hiperventilacion_1','hiperventilacion1','Hyper_1'};
Hyper_2 = {'hyperventilation_2','hiperventilacion_2','hiperventilacion1','Hyper_2'};
Hyper_3 = {'hyperventilation_3','hiperventilacion_3','hiperventilacion1','Hyper_3'};
Recover = {'recovery','recuperacion','recov','Recover'};
PhotoSt = {'photostimulation','fotoestimulacion','PhotoStimul','PhotoSt'};

events_translate = cell(7,4);
events_translate(1,:) = Op_eyes;
events_translate(2,:) = Cl_eyes;
events_translate(3,:) = Hyper_1;
events_translate(4,:) = Hyper_2;
events_translate(5,:) = Hyper_3;
events_translate(6,:) = Recover;
events_translate(7,:) = PhotoSt;

end