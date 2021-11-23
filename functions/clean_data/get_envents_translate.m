function events_translate = get_envents_translate()

Op_eyes = {'open_eyes','ojos_abiertos','eyes_opened','eyes_open','Op_eyes'};
Cl_eyes = {'closed_eyes','ojos_cerrados','eyes_closed','eyes_close','Cl_eyes'};
Hyper_1 = {'hyperventilation_1','hiperventilacion_1','hiperventilacion1','hiperventilacion 1','Hyper_1'};
Hyper_2 = {'hyperventilation_2','hiperventilacion_2','hiperventilacion2','hiperventilacion 2','Hyper_2'};
Hyper_3 = {'hyperventilation_3','hiperventilacion_3','hiperventilacion3','hiperventilacion 3','Hyper_3'};
Recover = {'recovery','recuperacion','recov','recover','Recover'};
PhotoSt = {'photostimulation','fotoestimulacion','PhotoStimul','Photo_Stimul','PhotoSt'};

events_translate = cell(7,5);
events_translate(1,:) = Op_eyes;
events_translate(2,:) = Cl_eyes;
events_translate(3,:) = Hyper_1;
events_translate(4,:) = Hyper_2;
events_translate(5,:) = Hyper_3;
events_translate(6,:) = Recover;
events_translate(7,:) = PhotoSt;

end