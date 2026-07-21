classdef AiIVEL_fianl < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        Label_16        matlab.ui.control.Label
        EditField_3     matlab.ui.control.EditField
        Label_15        matlab.ui.control.Label
        Label_14        matlab.ui.control.Label
        Label_13        matlab.ui.control.Label
        Label_12        matlab.ui.control.Label
        Label_11        matlab.ui.control.Label
        Label_10        matlab.ui.control.Label
        userLabel       matlab.ui.control.Label
        EditField_2     matlab.ui.control.EditField
        Label_9         matlab.ui.control.Label
        Label_8         matlab.ui.control.Label
        Label_7         matlab.ui.control.Label
        ContinueButton  matlab.ui.control.Button
        Label_5         matlab.ui.control.Label
        Label_4         matlab.ui.control.Label
        Label5          matlab.ui.control.Label
        EditField       matlab.ui.control.EditField
        StartButton     matlab.ui.control.Button
        Label_6         matlab.ui.control.Label
        Label_3         matlab.ui.control.Label
        AIagentLabel    matlab.ui.control.Label
        Label_2         matlab.ui.control.Label
        Label           matlab.ui.control.Label
        AiIVELLabel     matlab.ui.control.Label
        UIAxes5         matlab.ui.control.UIAxes
        UIAxes3_2       matlab.ui.control.UIAxes
        UIAxes3         matlab.ui.control.UIAxes
        UIAxes2         matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            %Play(app);
            app.Label_2.Text = '';
            app.Label_8.Text = '';
            global num_global;
            global t1_global;
            global mp3_global;
            global video_str;
            global new_vid_flag;
            global v_id;
            global cam;
            global timer_1;
            global video_level;
            global error_cnt;

            v_id=1;
            new_vid_flag=0;
            error_cnt=0;
            %             video_level=0;%影片等級2為video_2,1為video_1第一級
            video_level=str2double(app.EditField_3.Value);

            app.Label_14.Text=sprintf('Level %g',video_level);
            video_str=sprintf('video%g_%g_%g.mp4',1,video_level,v_id);


            import java.awt.*;
            import java.awt.event.*;

            %Create a Robot-object to do the key-pressing
            rob=Robot;
            recObj = audiorecorder(8000,16,1,1);

            disp("Begin speaking.")

            %faceGenderAgeEmotionDetection;
            %             open simple-pose-estimation.prj

            cam = webcam;
            detector = posenet.PoseEstimator;

            I = zeros(256,192,3,'uint8');
            cnt=1;
            %play video
            %             file_name='video_2_1.mp4';
            video_level
            v_id
            file_name=sprintf('video_%g_%g.mp4',video_level,v_id );
            videoReader = VideoReader(file_name);
            videoPlayer = vision.VideoPlayer;
            [audio,fs] = audioread(file_name);
            mp3player = audioplayer(audio,fs);
            mp3_global=mp3player;
            t_sec=length(audio)/fs;
            timer_1=tic;%計時作答時間
            load net_eye;
            load net_face_4;
            %leave detect
            n=0;
            %eye detect
            n1=0;
            %emotiom detect
            n_emotion=0;
            %sound detect
            i=0;
            init=1;
            %             rob.keyPress(KeyEvent.VK_F2); %產生鍵盤按F2鍵
            cnt2=0;
            t_slot=1;
            frame1=read(videoReader,1);
            %while cnt<50
            while 1
                if new_vid_flag==1
                    rob.keyRelease(KeyEvent.VK_F2);%放開F2
                    file_name=video_str;
                    videoReader = VideoReader(file_name);
                    cnt=1;
                    [audio,fs] = audioread(file_name);
                    mp3player = audioplayer(audio,fs);
                    mp3_global=mp3player;
                    t_sec=length(audio)/fs;
                    new_vid_flag=0;
                    timer_1=tic;%計時作答時間
                    app.Label_13.Text='';
                end

                rob.keyPress(KeyEvent.VK_F2);%按下F2
                record(recObj);
                pause(0.1);  %0.3
                try
                    y = getaudiodata(recObj);
                catch
                    y=0;
                end
                
                end1=length(y);
                win=y(init:end1);
                %                 win=(y(init:end1))*100;
                egy=(win'*win)/length(win); %說話的能量
                focus(app.EditField);
                pause(0.1);


                if i>=5 % 講話一句話停頓，就將文字存取
                    rob.keyPress(KeyEvent.VK_ENTER);
                    rob.keyRelease(KeyEvent.VK_ENTER);
                    pause(0.01);
                end

                init=end1;

                if egy<=0.1 %聲音能量小於0代表沒有說話，就停止
                    i=i+1;
                    if i==10000   %5
                        rob.keyRelease(KeyEvent.VK_F2);%放開F2
                        %rob.keyRelease(KeyEvent.VK_Tab);
                        break;
                    end
                else
                    i=0;
                end

                %情緒辨識
                %detector=vision.CascadeObjectDetector;
                detector1=vision.CascadeObjectDetector('MinSize',[20 20],'MergeThreshold',4);
                % detector=vision.CascadeObjectDetector('MergeThreshold',1);
                frame = snapshot(cam);
                %Show all block boxes.
                bbox= step(detector1,frame);
                [row,col]=size(bbox);
                %                 bbox=bbox(1,:);
                if row>=1
                    %                     cnt2=1:row;
                    box1=bbox(1,:);
                    box1(4)=box1(4)+60;
                    box1(2)=box1(2)-50;
                    out=insertObjectAnnotation(frame,'rectangle',box1,'','LineWidth',5);
                    imshow(out, 'Parent',app.UIAxes3_2);
                    axis(app.UIAxes3_2,'image');
                    %     imshow(out);
                    pause(0.01);
                    temp=box1;

                    if ~isempty(temp) % 確保 bbox 不為空
                        [rows, cols, ~] = size(frame); % 取得 frame 的尺寸
                        if temp(1) >= 1 && temp(2) >= 1 && temp(1) + temp(3) - 1 <= cols && temp(2) + temp(4) - 1 <= rows

                            im_face=frame(temp(2):temp(2)+temp(4)-1,temp(1):temp(1)+temp(3)-1,1);
                            im_face1=imresize(im_face,[120 80]);
                            face_result = classify(net_face_4, im_face1);

                            %app.Label_8.Text = face_result;
                            if face_result=='Confuse'
                                app.Label_8.Text = '困惑';
                            else
                                app.Label_8.Text = '正常';
                            end
                            %                     face_result='Confuse';
                            %                     app.Label_8.Text = face_result;


                            if face_result=='Confuse'
                                n_emotion=n_emotion+1;
                                if n_emotion==50 %5
                                    app.Label_2.Text = '可能有困惑喔！';
                                    num_global=t_slot;
                                    t1_global=toc(t1);
                                    stop(mp3player);
                                    rob.keyRelease(KeyEvent.VK_F2);%放開F2
                                    break;
                                end
                            else
                                n_emotion=0;

                            end
                        else
                            n_emotion=0;
                        end
                    else
                        n_emotion=0;
                    end
                else
                    imshow(frame, 'Parent',app.UIAxes3_2);
                    axis(app.UIAxes3_2,'image');
                end


                if cnt>1
                    t2=toc(t1);
                    t_slot=floor(t2/t_sec*videoReader.NumFrames);
                end
                if t_slot<=videoReader.NumFrames-1 && cnt>1
                    %frame1=read(videoReader,cnt);
                    frame1=read(videoReader,t_slot);
                end
                imshow(frame1, 'Parent',app.UIAxes5);

                if cnt==1
                    %frame1=read(videoReader,1);
                    play(mp3player);
                    t1=tic;
                    cnt=2;
                end
                cnt2=cnt2+1;

                if mod(cnt2,20)
                    %                     frame=snapshot(cam);
                    Iinresize = imresize(frame,[256 nan]);
                    Itmp = Iinresize(:,(size(Iinresize,2)-192)/2:(size(Iinresize,2)-192)/2+192-1,:);
                    Icrop = Itmp(1:256,1:192,1:3);

                    % Predict pose estimation
                    heatmaps = detector.predict(Icrop);
                    keypoints = detector.heatmaps2Keypoints(heatmaps);

                    % Visualize key points
                    Iout = detector.visualizeKeyPoints(Icrop,keypoints);
                    imshow(Iout, 'Parent',app.UIAxes2);
                    axis(app.UIAxes2,'image');

                    %leave detect
                    if keypoints(1:3,3)==0
                        n=n+1;
                        if n==10 
                            app.Label_2.Text = '離開座位了喔！';
                            num_global=t_slot;
                            t1_global=toc(t1);
                            stop(mp3player);
                            rob.keyRelease(KeyEvent.VK_F2);%放開F2
                            break;
                        end
                    else

                        n=0;
                    end

                    %eye detect
                    bodyDetector = vision.CascadeObjectDetector('EyePairBig');
                    bodyDetector.MinSize = [11 45];%[60 60]
                    bodyDetector.MergeThreshold = 10;
                    bboxBody = bodyDetector(frame);
                    [row,col]=size(bboxBody);
                    if row>=1
                        %                     try
                        IBody = insertObjectAnnotation(frame,'rectangle',bboxBody,'','LineWidth',5);
                        %figure;
                        %imshow(IBody);
                        imshow(IBody, 'Parent',app.UIAxes3);
                        axis(app.UIAxes3,'image');
                        y_idx1=bboxBody(2);
                        x_idx1=bboxBody(1);
                        x_idx2=x_idx1+bboxBody(3);
                        y_idx2=y_idx1+bboxBody(4);

                        if y_idx1 >= 1 && y_idx2 <= size(frame, 1) && x_idx1 >= 1 && x_idx2 <= size(frame, 2)%判斷如果有兩個框就跳過不要辨識
                            im2=frame(y_idx1:y_idx2,x_idx1:x_idx2,1:3);
                            im3=imresize(im2,[60 120]);

                            result = classify(net_eye, im3);
                            %app.Label_12.Text = result;
                            if result=='close'
                                app.Label_12.Text = '閉眼';
                            else
                                app.Label_12.Text = '正常';
                            end


                            if result=='close'

                                n1=n1+1;
                                if n1==10 %5
                                    app.Label_2.Text = '可能分心了喔！';
                                    num_global=t_slot;
                                    t1_global=toc(t1);
                                    stop(mp3player);
                                    rob.keyRelease(KeyEvent.VK_F2);%放開F2
                                    break;
                                end
                            else
                                n1=0;

                            end
                        else
                            n1=0;

                        end
                    else
                        imshow(frame, 'Parent',app.UIAxes3);
                        axis(app.UIAxes3,'image');

                    end
                end
            end
            clear cam;
            stop(recObj);
            disp("End of recording.");

        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            global new_vid_flag;
            global video_str;
            global v_id;
            global xlsname;%xls檔案名稱
            global user_name;%使用者名稱
            global Recog_cell; %recognized results, including text contents and recognized results.
            global timer_1;
            global y_match_ratio; %存分數
            global video_level %影片等級2為video_2,1為video_1第一級
            global error_cnt;%紀錄回答錯誤的次數
            global t_str;
            a= app.EditField.Value;
            str1=a;
            video_level=str2double(app.EditField_3.Value);
            len1=length(str1);
            %       如果開頭有標點符號就去掉
            match_ratio=0;%分數
            result3=0;%辨認是否通過

            if strcmp(str1(1),'，')||strcmp(str1(1),'？')||strcmp(str1(1),'。')||strcmp(str1(1),',')||strcmp(str1(1),'.')||strcmp(str1(1),'?')
                str1=str1(2:len1);
            end
            app.Label_5.Text=str1;
            str1=lower(str1);
            %       辨識回答的答案正不正確

            if video_level==2 %level 2等級

                switch v_id
                    case 1
                        app.Label_6.Text = 'sure';%提示文字
                        answer='sure';
                        keyword_n=1;
                        result3=strfind(str1,answer)

                        if result3>=1
                            match_ratio=1;
                        end
                    case 2
                        app.Label_6.Text = 'ok';
                        answer='ok';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 3
                        app.Label_6.Text = 'leave, October twenty first, return, December third';
                        answer='i would like to leave on october twenty first and return on december third';
                        same_no=0;
                        keyword={'would like to' 'leave on' 'october twenty first' 'return on' '21st' 'december' '3rd' 'october'};
                        keyword_n=8;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 4
                        app.Label_6.Text ='Oh, too bad';
                        answer='Oh, that is too bad';
                        same_no=0;
                        keyword={'oh' 'that is' 'too bad'};
                        keyword_n=3;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 5
                        app.Label_6.Text ='OK, great';
                        answer='OK,that would be great';
                        same_no=0;
                        keyword={'ok' 'that' 'would' 'would be' 'great'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 6
                        app.Label_6.Text ='Window seat, enjoy the view';
                        answer='Window seat,please. I would like to enjoy the view';
                        same_no=0;
                        keyword={'window seat' 'please' 'like to' 'enjoy' 'view'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 7
                        app.Label_6.Text ='allergic to seafood, have beef or chicken?';
                        answer='Oh,yes!I am allergic to seafood. Could I have beef or chicken?';
                        same_no=0;
                        keyword={'oh' 'yes' 'i am' 'allergic' 'seafood' 'could' 'have' 'beef' 'chicken'};
                        keyword_n=9;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 8
                        app.Label_6.Text = 'Great! Thank';
                        answer='Great! Thank you';
                        same_no=0;
                        keyword={'great' 'thank you' 'thank' 'you'};
                        keyword_n=4;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 9
                        app.Label_6.Text = 'earn miles, Eva Air';
                        answer='Yes,I earn miles when I fly with Eva Air';
                        same_no=0;
                        keyword={'yes' 'earn miles' 'when' 'fly with' 'eva air'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 10
                        app.Label_6.Text = 'morning flight';
                        answer='The morning flight,please';
                        same_no=0;
                        keyword={'morning' 'flight' 'please'};
                        keyword_n=3;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 11
                        app.Label_6.Text ='Chen, first name, Scott';
                        answer='Chen:c-h-e-n.And my first name is Scott';
                        same_no=0;
                        keyword={'chen' 'chen' 'and' 'my first name' 'first' 'name' 'scott'};
                        keyword_n=7;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 12
                        app.Label_6.Text ='What, mean?';
                        answer='What does that mean?';
                        same_no=0;
                        keyword={'what' 'does' 'that' 'mean'};
                        keyword_n=4;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 13
                        app.Label_6.Text ='understand, book now, miss the deadline';
                        answer='OK,I understand. I would better book now,just in case I miss the deadline';
                        same_no=0;
                        keyword={'ok' 'i understand' 'better' 'book' 'now' 'just' 'in case' 'miss' 'deadline'};
                        keyword_n=9;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 14
                        app.Label_6.Text ='credit card';
                        answer='By credit card,please. Here you go.';
                        same_no=0;
                        keyword={'by' 'credit card' 'please' 'here' 'you' 'go'};
                        keyword_n=6;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 15
                        app.Label_6.Text ='No problem';
                        answer='no problem';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 16
                        app.Label_6.Text ='Correct';
                        %answer='correct';
                        answer='correct';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 17
                        app.Label_6.Text ='No, for now';
                        answer='no,I think that is it for now';
                        same_no=0;
                        keyword={'no' 'think' 'that`s' 'for now' 'now'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 18
                        app.Label_6.Text ='Thank, Bye';
                        answer='Thank you. Bye';
                        same_no=0;
                        keyword={'thank you' 'bye'};
                        keyword_n=2;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.4
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 19
                        app.Label_6.Text ='Thank';
                        answer='thank you';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                end

                %error_cnt
                if error_cnt>=3
                    app.Label_13.Text = '你是否會覺得太難? 需要換簡單一級嗎?或者可以再嘗試';
                    answer_2={'好' '好啊' '可以' '需要' '要' 'please' '換簡單一點的' '太難了'};
                    for num1=1:length(answer_2)
                        str_temp=answer_2{num1};
                        if strfind(str1,str_temp)>=1
                            video_level=video_level-1;
                            error_cnt=0;%重設回答錯誤的計算次數
                            app.EditField_3.Value=num2str(video_level);
                            app.Label_13.Text = 'ok! 按下Contiune就會為您調降一級';
                            fprintf('切換成影片1');
                            v_id=1;
                            %result3=0;
                        end
                    end

                end


            elseif video_level==3 %level 13
                
                switch v_id
                    case 1
                        app.Label_6.Text = 'sure';%提示文字
                        answer='sure';
                        keyword_n=1;
                        result3=strfind(str1,answer)
                        if result3>=1
                            match_ratio=1;
                        end
                    case 2
                        app.Label_6.Text = 'ok';
                        answer='ok';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 3
                        app.Label_6.Text = 'October twenty first, December third';
                        answer='i would like to leave on october twenty first and return on december third';
                        same_no=0;
                        keyword={'would like to' 'leave on' 'october twenty first' 'return on' '21st' 'december' '3rd' 'october'};
                        keyword_n=8;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 4
                        app.Label_6.Text ='bad';
                        answer='Oh, that is too bad';
                        same_no=0;
                        keyword={'oh' 'that is' 'too bad'};
                        keyword_n=3;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 5
                        app.Label_6.Text ='great';
                        answer='OK,that would be great';
                        same_no=0;
                        keyword={'ok' 'that' 'would' 'would be' 'great'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 6
                        app.Label_6.Text ='Window seat, enjoy the view';
                        answer='Window seat,please. I would like to enjoy the view';
                        same_no=0;
                        keyword={'window seat' 'please' 'like to' 'enjoy' 'view'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 7
                        app.Label_6.Text ='allergic to seafood, beef or chicken?';
                        answer='Oh,yes!I am allergic to seafood. Could I have beef or chicken?';
                        same_no=0;
                        keyword={'oh' 'yes' 'i am' 'allergic' 'seafood' 'could' 'have' 'beef' 'chicken'};
                        keyword_n=9;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 8
                        app.Label_6.Text = 'Great!';
                        answer='Great! Thank you';
                        same_no=0;
                        keyword={'great' 'thank you' 'thank' 'you'};
                        keyword_n=4;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 9
                        app.Label_6.Text = 'earn miles, Eva Air';
                        answer='Yes,I earn miles when I fly with Eva Air';
                        same_no=0;
                        keyword={'yes' 'earn miles' 'when' 'fly with' 'eva air'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 10
                        app.Label_6.Text = 'morning flight';
                        answer='The morning flight,please';
                        same_no=0;
                        keyword={'morning' 'flight' 'please'};
                        keyword_n=3;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 11
                        app.Label_6.Text ='Chen, Scott';
                        answer='Chen:c-h-e-n.And my first name is Scott';
                        same_no=0;
                        keyword={'chen' 'chen' 'and' 'my first name' 'first' 'name' 'scott'};
                        keyword_n=7;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 12
                        app.Label_6.Text ='What';
                        answer='What does that mean?';
                        same_no=0;
                        keyword={'what' 'does' 'that' 'mean'};
                        keyword_n=4;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 13
                        app.Label_6.Text ='understand, book now, miss the deadline';
                        answer='OK,I understand. I would better book now,just in case I miss the deadline';
                        same_no=0;
                        keyword={'ok' 'i understand' 'better' 'book' 'now' 'just' 'in case' 'miss' 'deadline'};
                        keyword_n=9;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 14
                        app.Label_6.Text ='credit card';
                        answer='By credit card,please. Here you go.';
                        same_no=0;
                        keyword={'by' 'credit card' 'please' 'here' 'you' 'go'};
                        keyword_n=6;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 15
                        app.Label_6.Text ='No problem';
                        answer='no problem';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 16
                        app.Label_6.Text ='Correct';
                        %answer='correct';
                        answer='correct';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 17
                        app.Label_6.Text ='for now';
                        answer='no,I think that is it for now';
                        same_no=0;
                        keyword={'no' 'think' 'that`s' 'for now' 'now'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 18
                        app.Label_6.Text ='Bye';
                        answer='Thank you. Bye';
                        same_no=0;
                        keyword={'thank you' 'bye'};
                        keyword_n=2;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.3
                            result3=1;
                            app.Label_13.Text = '';
                            error_cnt=0;
                        else
                            result3=0;
                            error_cnt=error_cnt+1;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 19
                        app.Label_6.Text ='Thank';
                        answer='thank you';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                end
                %error_cnt
                if error_cnt>=3

                    app.Label_13.Text = '你是否會覺得太難? 需要換簡單一級嗎?或者可以再嘗試';
                    answer_2={'好' '好啊' '可以' '需要' '要' 'please'};
                    for num1=1:length(answer_2)
                        str_temp=answer_2{num1};
                        if strfind(str1,str_temp)>=1
                            video_level=video_level-1;
                            error_cnt=0;%重設回答錯誤的計算次數
                            app.EditField_3.Value=num2str(video_level);
                            app.Label_13.Text = 'ok! 按下Contiune就會為您調降一級';
                            fprintf('切換成影片1');
                            v_id=1;
                        end
                    end

                end


            elseif video_level==1  %level 1等級

                app.Label_6.Text = '';
                app.Label_13.Text = '';
                switch v_id
                    case 1
                        answer='sure';
                        keyword_n=1;
                        result3=strfind(str1,answer)

                        if result3>=1
                            match_ratio=1;
                        end
                    case 2
                        answer='ok';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 3
                        answer='i would like to leave on october twenty first and return on december third';
                        same_no=0;
                        keyword={'would like to' 'leave on' 'october twenty first' 'return on' '21st' 'december' '3rd' 'october'};
                        keyword_n=8;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 4
                        answer='Oh, that is too bad';
                        same_no=0;
                        keyword={'oh' 'that is' 'too bad'};
                        keyword_n=3;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 5
                        answer='OK,that would be great';
                        same_no=0;
                        keyword={'ok' 'that' 'would' 'would be' 'great'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 6
                        answer='Window seat,please. I would like to enjoy the view';
                        same_no=0;
                        keyword={'window seat' 'please' 'like to' 'enjoy' 'view'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 7
                        answer='Oh,yes!I am allergic to seafood. Could I have beef or chicken?';
                        same_no=0;
                        keyword={'oh' 'yes' 'i am' 'allergic' 'seafood' 'could' 'have' 'beef' 'chicken'};
                        keyword_n=9;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 8
                        answer='Great! Thank you';
                        same_no=0;
                        keyword={'great' 'thank you' 'thank' 'you'};
                        keyword_n=4;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 9
                        answer='Yes,I earn miles when I fly with Eva Air';
                        same_no=0;
                        keyword={'yes' 'earn miles' 'when' 'fly with' 'eva air'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 10
                        answer='The morning flight,please';
                        same_no=0;
                        keyword={'morning' 'flight' 'please'};
                        keyword_n=3;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 11
                        answer='Chen:c-h-e-n.And my first name is Scott';
                        same_no=0;
                        keyword={'chen' 'chen' 'and' 'my first name' 'first' 'name' 'scott'};
                        keyword_n=7;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 12
                        answer='What does that mean?';
                        same_no=0;
                        keyword={'what' 'does' 'that' 'mean'};
                        keyword_n=4;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_13.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 13
                        answer='OK,I understand. I would better book now,just in case I miss the deadline';
                        same_no=0;
                        keyword={'ok' 'i understand' 'better' 'book' 'now' 'just' 'in case' 'miss' 'deadline'};
                        keyword_n=9;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_6.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 14
                        answer='By credit card,please. Here you go.';
                        same_no=0;
                        keyword={'by' 'credit card' 'please' 'here' 'you' 'go'};
                        keyword_n=6;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_6.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 15
                        answer='no problem';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 16
                        %answer='correct';
                        answer='correct';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                    case 17
                        answer='no,I think that is it for now';
                        same_no=0;
                        keyword={'no' 'think' 'that`s' 'for now' 'now'};
                        keyword_n=5;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_6.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 18
                        answer='Thank you. Bye';
                        same_no=0;
                        keyword={'thank you' 'bye'};
                        keyword_n=2;
                        for num1=1:length(keyword)
                            str_temp=keyword{num1};
                            if strfind(str1,str_temp)>1
                                same_no=same_no+1;
                            end
                        end
                        match_ratio=same_no/length(keyword);
                        if match_ratio>0.5
                            result3=1;
                            app.Label_6.Text = '';
                        else
                            result3=0;
                            app.Label_13.Text = '再嘗試回答一次喔!';
                        end
                    case 19
                        answer='thank you';
                        keyword_n=1;
                        result3=strfind(str1,answer);
                        if result3>=1
                            match_ratio=1;
                        end
                end

            end


            if result3>=1 %exist answer
                %A={user_name,v_id,0,answer,str1,match_ratio};

                timetotal=toc(timer_1);%停止每一題的計時
                Recog_cell{v_id+1,1}=user_name;
                Recog_cell{v_id+1,2}=v_id;
                Recog_cell{v_id+1,3}=timetotal;%做題時間
                Recog_cell{v_id+1,4}=answer;
                Recog_cell{v_id+1,5}=str1; %Recognized result;
                Recog_cell{v_id+1,6}=match_ratio; %recognized score;
                Recog_cell{v_id+1,7}=keyword_n;%keyword數量
                Recog_cell(1:v_id+1,:)

                y_match_ratio(1,v_id)=match_ratio;%存取recognized score;
                timer_1=0;
                v_id=v_id+1;


                if v_id>=20  %%%%%%%%%%%%%%%% video number

                    video_level=string(app.EditField_3.Value);
                    xlsname=sprintf('%s_l%s_%s.xlsx',user_name,video_level,t_str)
                    %xlsname = strcat(user_name,'_l',video_level,'_',t_str,'.xlsx')

                    %xlswrite(string(xlsname),Recog_cell);

                    writecell(Recog_cell,string(xlsname));

                    %Recog_cell_1=array2table(Recog_cell)
                    %writetable(Recog_cell_1,string(xlsname),'WriteVariableNames',false,'Sheet','Sheet1','Range','A1')

                    x_match_ratio=1:19;
                    hold on;
                    plot(x_match_ratio,y_match_ratio, '-');
                    xlabel('Video index');
                    title('Keyword spot rate');
                    ylabel('Score');

                    return;
                else

                    app.Label_14.Text=sprintf('Level %g',video_level);
                    video_str=sprintf('video_%g_%g.mp4',video_level,v_id);
                    new_vid_flag=1;
                end

            end

            app.EditField.Value=' ';
        end

        % Button pushed function: ContinueButton
        function ContinueButtonPushed(app, event)
            %continue(app);
            app.Label_2.Text = '辨識中';
            app.Label_8.Text = '';
            app.Label_13.Text = '';
            %             global num_global;
            %             global t1_global;
            %             global mp3_global;
            global video_str;
            global new_vid_flag;
            global v_id;
            global timer_1;
            global video_level;
            global error_cnt;
            v_id
            
            app.Label_14.Text=sprintf('Level %g',video_level); 
            new_vid_flag=0;
            video_str=sprintf('video_%g_%g.mp4',video_level,v_id);

            %             video_str=sprintf('video_2_%g.mp4',v_id);
            %             new_vid_flag=0;
            %             global cam;
            import java.awt.*;
            import java.awt.event.*;
            %Create a Robot-object to do the key-pressing
            rob=Robot;
            recObj = audiorecorder(8000,16,1,1);

            disp("Begin speaking.")

            %faceGenderAgeEmoti Thank you. ByeonDetection;
            %             open simple-pose-estimation.prj

            cam = webcam;
            detector = posenet.PoseEstimator;

            I = zeros(256,192,3,'uint8');
            cnt=1;
            %play video
            file_name=video_str;

            videoReader = VideoReader(file_name);
            videoPlayer = vision.VideoPlayer;
            [audio,fs] = audioread(file_name);
            mp3player = audioplayer(audio,fs);
            mp3_global=mp3player;
            t_sec=length(audio)/fs;
            timer_1=tic;%計時作答時間
            load net_eye;
            load net_face_4;
            %leave detect
            n=0;
            %eye detect
            n1=0;
            %emotiom detect
            n_emotion=0;
            %sound detect
            i=0;
            init=1;
            rob.keyPress(KeyEvent.VK_F2); %產生鍵盤按F2鍵

            cnt2=0;
            t_slot=1;
            frame1=read(videoReader,1);
            %while cnt<50
            while 1
                if new_vid_flag==1
                    rob.keyRelease(KeyEvent.VK_F2);%放開F2
                    file_name=video_str;
                    videoReader = VideoReader(file_name);
                    cnt=1;
                    [audio,fs] = audioread(file_name);
                    mp3player = audioplayer(audio,fs);
                    mp3_global=mp3player;
                    t_sec=length(audio)/fs;
                    new_vid_flag=0;
                    timer_1=tic;%計時作答時間
                    app.Label_13.Text='';
                end

                rob.keyPress(KeyEvent.VK_F2);
                record(recObj);
                pause(0.1);  %0.3
                try
                    y = getaudiodata(recObj);
                catch
                    y=0;
                end
                end1=length(y);
                win=y(init:end1);
                %                 win=(y(init:end1))*100;
                egy=(win'*win)/length(win); %說話的能量
                focus(app.EditField);
                pause(0.1);

                if i>=3 % 講話一句話停頓，就將文字存取

                    rob.keyPress(KeyEvent.VK_ENTER);
                    rob.keyRelease(KeyEvent.VK_ENTER);

                    pause(0.01);
                end

                init=end1;

                if egy<=0.1 %聲音能量小於0代表沒有說話，就停止
                    i=i+1;
                    if i==10000   %5
                        rob.keyRelease(KeyEvent.VK_F2);%放開F2
                        %rob.keyRelease(KeyEvent.VK_Tab);
                        break;
                    end
                else
                    i=0;
                end

                %情緒辨識
                %detector=vision.CascadeObjectDetector;
                detector1=vision.CascadeObjectDetector('MinSize',[20 20],'MergeThreshold',4);
                % detector=vision.CascadeObjectDetector('MergeThreshold',1);
                frame= snapshot(cam);
                %Show all block boxes.
                bbox= step(detector1,frame);
                %                 bbox=bbox(1,:);
                [row,col]=size(bbox);
                if row>=1
                    %                     cnt2=1:row;
                    box1=bbox(1,:);
                    box1(4)=box1(4)+60;
                    box1(2)=box1(2)-50;
                    out=insertObjectAnnotation(frame,'rectangle',box1,'','LineWidth',5);
                    imshow(out, 'Parent',app.UIAxes3_2);
                    axis(app.UIAxes3_2,'image');
                    %     imshow(out);
                    pause(0.01);
                    temp=box1;

                    if ~isempty(temp) % 確保 bbox 不為空
                        [rows, cols, ~] = size(frame); % 取得 frame 的尺寸
                        if temp(1) >= 1 && temp(2) >= 1 && temp(1) + temp(3) - 1 <= cols && temp(2) + temp(4) - 1 <= rows

                            im_face=frame(temp(2):temp(2)+temp(4)-1,temp(1):temp(1)+temp(3)-1);
                            im_face1=imresize(im_face,[120 80]);
                            face_result = classify(net_face_4, im_face1);
                            %app.Label_8.Text = face_result;
                            if face_result=='Confuse'
                                app.Label_8.Text = '困惑';
                            else
                                app.Label_8.Text = '正常';
                            end

                            if face_result=='Confuse'
                                n_emotion=n_emotion+1;
                                if n_emotion==15%5
                                    app.Label_2.Text = '可能有困惑喔！';
                                    num_global=t_slot;
                                    t1_global=toc(t1);
                                    stop(mp3player);
                                    rob.keyRelease(KeyEvent.VK_F2);%放開F2
                                    break;
                                end
                            else
                                n_emotion=0;

                            end
                        else
                            n_emotion=0;
                        end
                    else
                        n_emotion=0;
                    end

                end

                if cnt>1
                    t2=toc(t1);
                    t_slot=floor(t2/t_sec*videoReader.NumFrames);
                end
                if t_slot<=videoReader.NumFrames-1 && cnt>1
                    %frame1=read(videoReader,cnt);
                    frame1=read(videoReader,t_slot);
                end
                imshow(frame1, 'Parent',app.UIAxes5);

                if cnt==1
                    %frame1=read(videoReader,1);
                    play(mp3player);
                    t1=tic;
                    cnt=2;
                end
                cnt2=cnt2+1;

                if mod(cnt2,20)
                    %                     frame=snapshot(cam);
                    Iinresize = imresize(frame,[256 nan]);
                    Itmp = Iinresize(:,(size(Iinresize,2)-192)/2:(size(Iinresize,2)-192)/2+192-1,:);
                    Icrop = Itmp(1:256,1:192,1:3);

                    % Predict pose estimation
                    heatmaps = detector.predict(Icrop);
                    keypoints = detector.heatmaps2Keypoints(heatmaps);

                    % Visualize key points
                    Iout = detector.visualizeKeyPoints(Icrop,keypoints);
                    imshow(Iout, 'Parent',app.UIAxes2);
                    axis(app.UIAxes2,'image');

                    %leave detect
                    if keypoints(1:3,3)==0
                        n=n+1;
                        if n==10
                            app.Label_2.Text = '離開座位了喔！';
                            %                             num_global=t_slot;
                            %                             t1_global=toc(t1);
                            stop(mp3player);
                            rob.keyRelease(KeyEvent.VK_F2);%放開F2
                            break;
                        end
                    else

                        n=0;
                    end

                    %eye detect
                    bodyDetector = vision.CascadeObjectDetector('EyePairBig');
                    bodyDetector.MinSize = [11 45];%[60 60]
                    bodyDetector.MergeThreshold = 10;
                    bboxBody = bodyDetector(frame);
                    [row,col]=size(bboxBody);
                    if row>=1
                        IBody = insertObjectAnnotation(frame,'rectangle',bboxBody,'','LineWidth',5);
                        %figure;
                        %imshow(IBody);
                        imshow(IBody, 'Parent',app.UIAxes3);
                        axis(app.UIAxes3,'image');
                        y_idx1=bboxBody(2);
                        x_idx1=bboxBody(1);
                        x_idx2=x_idx1+bboxBody(3);
                        y_idx2=y_idx1+bboxBody(4);

                        if y_idx1 >= 1 && y_idx2 <= size(frame, 1) && x_idx1 >= 1 && x_idx2 <= size(frame, 2)
                            im2=frame(y_idx1:y_idx2,x_idx1:x_idx2,1:3);
                            im3=imresize(im2,[60 120]);
                            result = classify(net_eye, im3)
                            %app.Label_12.Text = result;
                            if result=='close'
                                app.Label_12.Text = '閉眼';
                            else
                                app.Label_12.Text = '正常';
                            end

                            if result=='close'
                                n1=n1+1;
                                if n1==30   %5
                                    app.Label_2.Text = '可能分心了喔！';
                                    %                             num_global=t_slot;
                                    %                             t1_global=toc(t1);
                                    stop(mp3player);
                                    rob.keyRelease(KeyEvent.VK_F2);%放開F2
                                    break;
                                end
                            else
                                n1=0;
                            end
                        else
                            n1=0;
                        end
                    else
                        imshow(frame, 'Parent',app.UIAxes3);
                        axis(app.UIAxes3,'image');
                    end
                end
            end
            clear cam;
            stop(recObj);
            disp("End of recording.");
        end

        % Value changed function: EditField_2
        function EditField_2ValueChanged(app, event)
            global user_name;
            global Recog_cell;
            global y_match_ratio;%存分數
            global video_level;
            global t_str;
            video_level=app.EditField_3.Value;
            user_name = app.EditField_2.Value;
            t = datetime('now','TimeZone','local','Format','y_M_d_HH_mm')
            t_str=string(t);
            Recog_cell=cell(20,7);
            Recog_cell(1,:)={'User name','Video index','Elapse time','Target sentence','Recognized sentence','Keyword spot rate','Keyword'};
            y_match_ratio=zeros(1,19);%分數存取的矩陣
            user_name=lower(user_name);%將名字轉成小寫
            app.userLabel.Text=user_name;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9137 0.9176 0.9451];
            app.UIFigure.Position = [100 100 901 606];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            app.UIAxes2.AmbientLightColor = 'none';
            app.UIAxes2.Alphamap = [0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9529 0.9683 0.9841 1];
            app.UIAxes2.XTick = [];
            app.UIAxes2.XTickLabelRotation = 0;
            app.UIAxes2.YTick = [];
            app.UIAxes2.YTickLabelRotation = 0;
            app.UIAxes2.ZTickLabelRotation = 0;
            app.UIAxes2.Color = 'none';
            app.UIAxes2.Box = 'on';
            app.UIAxes2.Position = [526 21 99 101];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            app.UIAxes3.AmbientLightColor = 'none';
            app.UIAxes3.Alphamap = [0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9529 0.9683 0.9841 1];
            app.UIAxes3.XTick = [];
            app.UIAxes3.XTickLabelRotation = 0;
            app.UIAxes3.YTick = [];
            app.UIAxes3.YTickLabelRotation = 0;
            app.UIAxes3.ZTickLabelRotation = 0;
            app.UIAxes3.Color = 'none';
            app.UIAxes3.Box = 'on';
            app.UIAxes3.Position = [652 20 101 101];

            % Create UIAxes3_2
            app.UIAxes3_2 = uiaxes(app.UIFigure);
            app.UIAxes3_2.AmbientLightColor = 'none';
            app.UIAxes3_2.Alphamap = [0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9529 0.9683 0.9841 1];
            app.UIAxes3_2.XTick = [];
            app.UIAxes3_2.XTickLabelRotation = 0;
            app.UIAxes3_2.YTick = [];
            app.UIAxes3_2.YTickLabelRotation = 0;
            app.UIAxes3_2.ZTickLabelRotation = 0;
            app.UIAxes3_2.Color = 'none';
            app.UIAxes3_2.Box = 'on';
            app.UIAxes3_2.Position = [778 21 97 100];

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.UIFigure);
            app.UIAxes5.XTick = [];
            app.UIAxes5.YTick = [];
            app.UIAxes5.Color = 'none';
            app.UIAxes5.Box = 'on';
            app.UIAxes5.Position = [29 258 845 305];

            % Create AiIVELLabel
            app.AiIVELLabel = uilabel(app.UIFigure);
            app.AiIVELLabel.HorizontalAlignment = 'center';
            app.AiIVELLabel.FontName = 'Microsoft JhengHei UI';
            app.AiIVELLabel.FontSize = 20;
            app.AiIVELLabel.FontWeight = 'bold';
            app.AiIVELLabel.Position = [328 570 245 26];
            app.AiIVELLabel.Text = 'AiIVEL英文學習系統';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.FontName = 'Microsoft JhengHei UI';
            app.Label.FontSize = 16;
            app.Label.FontWeight = 'bold';
            app.Label.Position = [610 227 106 22];
            app.Label.Text = '學習狀態：';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.VerticalAlignment = 'top';
            app.Label_2.FontSize = 16;
            app.Label_2.Position = [610 166 121 51];
            app.Label_2.Text = '辨別中...';

            % Create AIagentLabel
            app.AIagentLabel = uilabel(app.UIFigure);
            app.AIagentLabel.FontName = 'Microsoft JhengHei UI';
            app.AIagentLabel.FontSize = 16;
            app.AIagentLabel.FontWeight = 'bold';
            app.AIagentLabel.Position = [24 195 121 22];
            app.AIagentLabel.Text = 'AI agent：';

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.FontName = 'Microsoft JhengHei UI';
            app.Label_3.FontSize = 16;
            app.Label_3.FontWeight = 'bold';
            app.Label_3.Position = [24 82 191 22];
            app.Label_3.Text = '學習者回答辨識結果：';

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.FontSize = 16;
            app.Label_6.Position = [24 110 473 22];
            app.Label_6.Text = '';

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.6 0.3882 0.4118];
            app.StartButton.FontSize = 16;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.FontColor = [1 1 1];
            app.StartButton.Position = [741 221 134 28];
            app.StartButton.Text = 'Start';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'text');
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.FontSize = 16;
            app.EditField.Position = [24 53 477 22];

            % Create Label5
            app.Label5 = uilabel(app.UIFigure);
            app.Label5.Position = [-92 675 2 2];
            app.Label5.Text = 'Label5';

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.Position = [24 22 78 22];
            app.Label_4.Text = '存取的文字：';

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.Position = [102 22 399 22];
            app.Label_5.Text = '';

            % Create ContinueButton
            app.ContinueButton = uibutton(app.UIFigure, 'push');
            app.ContinueButton.ButtonPushedFcn = createCallbackFcn(app, @ContinueButtonPushed, true);
            app.ContinueButton.BackgroundColor = [0.4824 0.5176 0.6275];
            app.ContinueButton.FontSize = 16;
            app.ContinueButton.FontColor = [1 1 1];
            app.ContinueButton.Position = [740 182 135 28];
            app.ContinueButton.Text = 'Continue';

            % Create Label_7
            app.Label_7 = uilabel(app.UIFigure);
            app.Label_7.FontSize = 16;
            app.Label_7.FontWeight = 'bold';
            app.Label_7.Position = [442 227 85 22];
            app.Label_7.Text = '情緒狀態：';

            % Create Label_8
            app.Label_8 = uilabel(app.UIFigure);
            app.Label_8.FontSize = 16;
            app.Label_8.Position = [526 227 71 22];
            app.Label_8.Text = '';

            % Create Label_9
            app.Label_9 = uilabel(app.UIFigure);
            app.Label_9.FontSize = 16;
            app.Label_9.FontWeight = 'bold';
            app.Label_9.Position = [24 227 79 22];
            app.Label_9.Text = '輸入姓名 :';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.UIFigure, 'text');
            app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
            app.EditField_2.FontSize = 16;
            app.EditField_2.Position = [114 227 119 22];

            % Create userLabel
            app.userLabel = uilabel(app.UIFigure);
            app.userLabel.FontSize = 16;
            app.userLabel.Position = [806 567 94 31];
            app.userLabel.Text = 'user';

            % Create Label_10
            app.Label_10 = uilabel(app.UIFigure);
            app.Label_10.FontSize = 16;
            app.Label_10.FontWeight = 'bold';
            app.Label_10.Position = [722 572 85 22];
            app.Label_10.Text = '使用者為：';

            % Create Label_11
            app.Label_11 = uilabel(app.UIFigure);
            app.Label_11.FontSize = 16;
            app.Label_11.FontWeight = 'bold';
            app.Label_11.Position = [442 195 85 22];
            app.Label_11.Text = '眼睛狀態：';

            % Create Label_12
            app.Label_12 = uilabel(app.UIFigure);
            app.Label_12.FontSize = 16;
            app.Label_12.Position = [526 195 71 22];
            app.Label_12.Text = '';

            % Create Label_13
            app.Label_13 = uilabel(app.UIFigure);
            app.Label_13.FontSize = 16;
            app.Label_13.Position = [24 166 470 22];
            app.Label_13.Text = '';

            % Create Label_14
            app.Label_14 = uilabel(app.UIFigure);
            app.Label_14.FontSize = 16;
            app.Label_14.Position = [12 568 90 30];
            app.Label_14.Text = '';

            % Create Label_15
            app.Label_15 = uilabel(app.UIFigure);
            app.Label_15.HorizontalAlignment = 'right';
            app.Label_15.FontSize = 16;
            app.Label_15.FontWeight = 'bold';
            app.Label_15.Position = [248 227 85 22];
            app.Label_15.Text = '學習階數：';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.UIFigure, 'text');
            app.EditField_3.FontSize = 16;
            app.EditField_3.Position = [335 228 91 21];

            % Create Label_16
            app.Label_16 = uilabel(app.UIFigure);
            app.Label_16.FontSize = 16;
            app.Label_16.FontWeight = 'bold';
            app.Label_16.Position = [24 138 104 22];
            app.Label_16.Text = '關鍵字提示：';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AiIVEL_fianl

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end