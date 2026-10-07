#pragma once
#include <cmath>

class AudioNoiseFilter
{
public:
    void setNoiseGate(float threshold){m_threshold=threshold;}
    bool acceptFrame(float rms) const{
        return std::isfinite(rms) && rms >= m_threshold;
    }
private:
    float m_threshold=0.015f;
};
