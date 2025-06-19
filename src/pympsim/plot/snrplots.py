import matplotlib.pyplot as plt
import numpy as np


def snr_plot(snr_struct, ax=None,title='SNR Plot', label=None,xscale=None,**kwargs):
    
    
    x = snr_struct.sat.elev[:,0]
    xlabel='Elevation [deg]'
    if xscale is not None and xscale == 'sine':
        xlabel='Sin(Elevation)'
        x= np.sin(np.radians(x))
    
    if ax is None:
        fig, ax = plt.subplots()

        ax.set_title(title)
        ax.set_xlabel(xlabel)
        if xscale is not None and xscale != 'sine':
            ax.set_xscale(xscale)
        
        ax.set_ylabel('SNR Db')

    ax.plot(x, snr_struct.snr_db[:,0], label=label, **kwargs)
    if label is not None:
        ax.legend()
    return ax
