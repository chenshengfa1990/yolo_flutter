// Tencent is pleased to support the open source community by making ncnn available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company. All rights reserved.
//
// Licensed under the BSD 3-Clause License (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the License at
//
// https://opensource.org/licenses/BSD-3-Clause
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

package com.flutter.yolo.opencv_plugin;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class OpenCvDetectModel
{
    public float x;
    public float y;
    public float w;
    public float h;
    public String label;
    public float prob;

    public OpenCvDetectModel(int imgX, int imgY, int imgWidth, int imgHeight) {
        this.x = imgX;
        this.y = imgY;
        this.w = imgWidth;
        this.h = imgHeight;
    }

    String toJson() {
        Map<String, Object> objMap = new HashMap<String, Object>();
        objMap.put("x", this.x);
        objMap.put("y", this.y);
        objMap.put("w", this.w);
        objMap.put("h", this.h);
        objMap.put("label", this.label);
        objMap.put("prob", this.prob);
        return new JSONObject(objMap).toString();
    }
}
