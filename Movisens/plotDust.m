% plotDust() MATLAB function: Make & charterize distributions 
% of datapoints in multi-dimesnsions, plotting capabilities in 1 to 6D
% INITIATED:  2020-12-28 by patton from some old code
function plotDust(x,nBins)
fprintf('\n_____\n  ~ plotDust: Distribution analysis & Plot ~  ')
clf; drawnow, pause(.01)
if ~exist('nBins','var'), nBins=10; end       % default if not given
if ~exist('x','var'), % default if not given, make fake multimodal distrib
  fprintf('SYNTAX: plotDust(x,nBins);   No x given; randomly generating')
  nDim=3; N=5000; 
  x=[randn(round(N/4),nDim)*2; .05*randn(round(N/4),nDim); .1*randn(round(N/4),nDim)-1; (randn(round(N/4),nDim)+3)*randn(nDim,nDim)]; x(:,1)=x(:,1)+7; % create a multimodal distrib & shift right just for fun
end       
[N,nDim]=size(x);
[counts,binLimits,binCenters]=countInBins(x,nBins); % fast-sort histogram

%% Plot points, 1D-6D, and histogram summary to summarize 
fprintf('\n plotting (%d points, %d dimensions, %d Bins)...',N,nDim,nBins); 
switch nDim
  case 1      % nDim==1 
    xPos=randn(size(x));
    plot(xPos,x(:,1),'.'); hold on; ax=axis;
    for j1=1:nBins, plot(zeros(size(binCenters)),binCenters(j1), ...
        'o','markerSize',1000*counts(j1)/(5*N)+1, ...
        'MarkerEdgeColor','w', 'MarkerFaceColor','r');
      text(0,binCenters(j1,1), ...
       ['' num2str(counts(j1))],'fontSize',7,'Color','k');
    end
    for j1=1:nBins+1,
      plot(ax(1:2),binLimits(j1,1)*[1 1],'g:'); % line showing bins
    end
    plot(xPos,x(:,1),'.'); % plot dots again on top

case 2      % nDim==2 
  plot(x(:,1),x(:,2),'b.'); hold on; ax=axis;
  for j1=1:nBins
    for j2=1:nBins
      plot(binCenters(j1,1),binCenters(j2,2),'o', ...
       'markerSize',300*counts(j1,j2)/N+.9, ...
       'MarkerEdgeColor','w', 'MarkerFaceColor','r');
     if counts(j1,j2)>0,
       text(binCenters(j1,1),binCenters(j2,2), ...
         ['' num2str(counts(j1,j2))],'fontSize',7,'Color','k');
     end
      plot(binLimits(j1,1)*[1 1], [ax(3), ax(4)],'k:'); % line showing bins
      plot([ax(1), ax(2)], binLimits(j2,2)*[1 1],'k:'); % line showing bins
    end
  end
  plot(binLimits(j1+1,1)*[1 1], [ax(3), ax(4)],'k:'); % line showing final bin
  plot([ax(1), ax(2)], binLimits(j2+1,2)*[1 1],'k:'); % line showing final bin
  plot(x(:,1),x(:,2),'b.');  % plot again
  
case 3      % nDim==3 
  plot3(x(:,1),x(:,2),x(:,3),'b.'); ax=axis; hold on;  grid on; 
  for j1=1:nBins
    for j2=1:nBins
      for j3=1:nBins
        plot3(binCenters(j1,1),binCenters(j2,2),binCenters(j3,3),'o', ...
          'markerSize',nBins*50*counts(j1,j2,j3)/N+1, 'MarkerEdgeColor','w', 'MarkerFaceColor','r');
        if counts(j1,j2,j3)>0,
          text(binCenters(j1,1),binCenters(j2,2),binCenters(j3,3), ...
            ['' num2str(counts(j1,j2,j3))],'fontSize',7,'Color','k');
        end
        plot3(binLimits(j1,1)*[1 1], binLimits(j2,2)*[1 1], [ax(5), ax(6)],'g:'); % line showing bins
        plot3(binLimits(j1,1)*[1 1], [ax(3), ax(4)], binLimits(j3,3)*[1 1],'g:'); % line showing bins
        plot3([ax(1), ax(2)], binLimits(j2,2)*[1 1], binLimits(j3,3)*[1 1],'g:'); % line showing bins
      end
    end
          drawnow; pause(.01); % update display while you go
  end
  plot3(x(:,1),x(:,2),x(:,3),'b.'); % plot again
  
case 4      % nDim==4 
  plot(x(:,1),x(:,2),'b.');  drawnow; pause(.01); hold on; axis equal; ax=axis; 
  simpleArrow(x(:,1:2),x(:,1:2)+.1*x(:,3:4),'b'); drawnow; pause(.01);
  for j1=1:nBins
    for j2=1:nBins
      for j3=1:nBins
        for j4=1:nBins
          plot(binCenters(j1,1),binCenters(j2,2),'o', ...
            'MarkerSize',100*sum(sum(counts(j1,j2,:,:)))/N+1, ...
            'MarkerEdgeColor','w', 'MarkerFaceColor','r');
          Bs=[binCenters(j1,1) binCenters(j2,2)];
          Be=[binCenters(j3,3) binCenters(j4,4)];
          simpleArrow(Bs,Bs+.5*Be,'m',50*counts(j1,j2,j3,j4)/N); % red arrow
          plot(binLimits(j1,1)*[1 1], [ax(3), ax(4)],'k:'); % line showing bins
          plot([ax(1), ax(2)], binLimits(j2,2)*[1 1],'k:'); % line showing bins
        end
      end
      drawnow; pause(.01); % update display while you go
    end
  end
  plot(binLimits(j1+1,1)*[1 1], [ax(3), ax(4)],'k:'); % line showing final bin
  plot([ax(1), ax(2)], binLimits(j2+1,2)*[1 1],'k:'); % line showing final bin

  % plot points again
%   plot(x(:,1),x(:,2),'b.');  drawnow; pause(.01); hold on;
%   simpleArrow(x(:,1:2),x(:,1:2)+.1*x(:,3:4),'b');
  
case 5
  fprintf('no plotting capabilites yet for dimensionaly 5 yet, but looking for creative ideas!');
  
case 6      % nDim==6
  plot3(x(:,1),x(:,2),x(:,3),'b.');  drawnow; pause(.01); hold on; axis equal; ax=axis; 
  simpleArrow(x(:,1:3),x(:,1:3)+.1*x(:,4:6),'b'); drawnow; pause(.01);
  for j1=1:nBins
    for j2=1:nBins
      for j3=1:nBins
        for j4=1:nBins
          for j5=1:nBins
            for j6=1:nBins
              plot3(binCenters(j1,1),binCenters(j2,2),binCenters(j3,3),'o', ...
                'MarkerSize',100*sum(sum(sum(counts(j1,j2,j3,:,:,:))))/N+1, ...
                'MarkerEdgeColor','w', 'MarkerFaceColor','r');
              Bs=[binCenters(j1,1) binCenters(j2,2) binCenters(j3,3)];
              Be=[binCenters(j4,4) binCenters(j5,5) binCenters(j3,6) ];
              simpleArrow(Bs,Bs+.1*Be,'m',500*counts(j1,j2,j3,j4)/N+1); % magenta arrow
              plot3(binLimits(j1,1)*[1 1], binLimits(j2,2)*[1 1], [ax(5), ax(6)],'g:'); % line showing bins
              plot3(binLimits(j1,1)*[1 1], [ax(3), ax(4)], binLimits(j3,3)*[1 1],'g:'); % line showing bins
              plot3([ax(1), ax(2)], binLimits(j2,2)*[1 1], binLimits(j3,3)*[1 1],'g:'); % line showing bins
            end
          end
        end
      end
      drawnow; pause(.001); % update display while you go
    end
  end
  plot(binLimits(j1+1,1)*[1 1], [ax(3), ax(4)],'k:'); % line showing final bin
  plot([ax(1), ax(2)], binLimits(j2+1,2)*[1 1],'k:'); % line showing final bin

  % plot points again
  plot3(x(:,1),x(:,2),x(:,3),'b.');  
  simpleArrow(x(:,1:3),x(:,1:3)+.1*x(:,4:6),'b'); 

otherwise
  fprintf('no functionality for dimension %d', nDim )
            
end % END case switch
fprintf('\n ~ END plotDust ~ \n')

end % END function

